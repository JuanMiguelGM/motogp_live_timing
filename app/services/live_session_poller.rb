# frozen_string_literal: true

require 'concurrent'

class LiveSessionPoller
  TIMING_INTERVAL = 5
  LOG_TAG = '[LiveSessionPoller]'

  attr_reader :session

  def initialize(session, client: MotoGpClient.new)
    @session = session
    @client = client
    @timing_sync = Sync::TimingSync.new(client: @client)
    @positions_sync = Sync::PositionsSync.new(client: @client)
    @race_direction_sync = Sync::RaceDirectionSync.new(client: @client)
    @weather_sync = Sync::WeatherSync.new(client: @client)
    @running = false
    @task = nil
  end

  def start
    return if @running

    @running = true
    Rails.logger.info "#{LOG_TAG} Starting poller for session #{@session.id} (#{@session.session_type})"

    @task = Concurrent::TimerTask.new(execution_interval: TIMING_INTERVAL) do
      poll_and_broadcast
    end
    @task.execute
  end

  def stop
    return unless @running

    @running = false
    @task&.shutdown
    Rails.logger.info "#{LOG_TAG} Stopped poller for session #{@session.id}"
  end

  def running?
    @running
  end

  private

  def poll_and_broadcast
    poll_timing
    poll_positions
    poll_race_direction
    poll_weather
  rescue MotoGpClient::ApiError => e
    Rails.logger.warn "#{LOG_TAG} API error for session #{@session.id}: #{e.message}"
  rescue StandardError => e
    Rails.logger.error "#{LOG_TAG} Unexpected error for session #{@session.id}: #{e.message}"
  end

  def poll_timing
    @timing_sync.call(session: @session)
    entries = @session.timing_entries.includes(rider: :team).by_position
    broadcast(:timing_update, entries: entries.map { |e| timing_entry_data(e) })
  end

  def poll_positions
    @positions_sync.call(session: @session)
    bike_positions = @session.bike_positions.includes(rider: :team)
    broadcast(:position_update, positions: bike_positions.map { |bp| bike_position_data(bp) })
  end

  def broadcast(type, payload)
    SessionChannel.broadcast_to(@session, { type: type, **payload })
  end

  def timing_entry_data(entry)
    rider = entry.rider
    {
      rider_number: rider.number,
      rider_acronym: rider.name_acronym,
      team_colour: rider.team.colour,
      position: entry.position,
      gap_to_leader: entry.gap_to_leader,
      interval: entry.interval,
      last_lap_time: entry.last_lap_time,
      best_lap_time: entry.best_lap_time,
      sector_1_time: entry.sector_1_time,
      sector_2_time: entry.sector_2_time,
      sector_3_time: entry.sector_3_time,
      top_speed: entry.top_speed,
      total_laps: entry.total_laps,
      status: entry.status,
      pit_stop_count: entry.pit_stop_count,
      speed_trap: entry.speed_trap
    }
  end

  def bike_position_data(bike_pos)
    {
      rider_number: bike_pos.rider.number,
      rider_acronym: bike_pos.rider.name_acronym,
      team_colour: bike_pos.rider.team.colour,
      x: bike_pos.x,
      y: bike_pos.y,
      z: bike_pos.z
    }
  end

  def poll_race_direction
    @race_direction_sync.call(session: @session)
    messages = @session.race_direction_messages.by_time.limit(20)
    latest_flag = @session.race_direction_messages.flags_only.by_time.first
    broadcast(:race_direction_update,
              messages: messages.map { |m| race_direction_data(m) },
              current_flag: latest_flag&.flag)
  end

  def poll_weather
    @weather_sync.call(session: @session)
    snapshot = @session.weather_snapshots.latest.first
    return unless snapshot

    broadcast(:weather_update, weather: weather_data(snapshot))
  end

  def race_direction_data(msg)
    {
      category: msg.category,
      flag: msg.flag,
      scope: msg.scope,
      sector: msg.sector,
      message: msg.message,
      recorded_at: msg.recorded_at&.iso8601
    }
  end

  def weather_data(snapshot)
    {
      air_temperature: snapshot.air_temperature,
      track_temperature: snapshot.track_temperature,
      humidity: snapshot.humidity,
      wind_speed: snapshot.wind_speed,
      wind_direction: snapshot.wind_direction,
      rainfall: snapshot.rainfall
    }
  end
end
