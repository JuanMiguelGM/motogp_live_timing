# frozen_string_literal: true

class SessionsController < ApplicationController
  before_action :set_session

  def show
    @timing_entries = @session.timing_entries.includes(rider: :team).by_position
    @bike_positions = @session.bike_positions.includes(rider: :team)
    @event = @session.event
    @weather = @session.weather_snapshots.latest.first
    @race_direction_messages = @session.race_direction_messages.by_time.limit(20)
  end

  def timing_data
    entries = @session.timing_entries.includes(rider: :team).by_position

    render json: entries.map { |e| timing_entry_json(e) }
  end

  def positions
    bike_positions = @session.bike_positions.includes(rider: :team)

    render json: bike_positions.map { |bp| bike_position_json(bp) }
  end

  private

  def set_session
    @session = Session.includes(event: :circuit).find(params[:id])
  end

  def timing_entry_json(entry)
    rider = entry.rider
    {
      rider_number: rider.number,
      rider_acronym: rider.name_acronym,
      team_colour: rider.team.colour,
      **timing_fields(entry),
      **sector_fields(entry),
      top_speed: entry.top_speed,
      total_laps: entry.total_laps,
      status: entry.status,
      pit_stop_count: entry.pit_stop_count,
      speed_trap: entry.speed_trap
    }
  end

  def timing_fields(entry)
    {
      position: entry.position, gap_to_leader: entry.gap_to_leader,
      interval: entry.interval, last_lap_time: entry.last_lap_time,
      best_lap_time: entry.best_lap_time
    }
  end

  def sector_fields(entry)
    (1..3).each_with_object({}) do |s, hash|
      hash[:"sector_#{s}_time"] = entry.send(:"sector_#{s}_time")
      hash[:"sector_#{s}_pb"] = entry.send(:"sector_#{s}_pb")
      hash[:"sector_#{s}_sb"] = entry.send(:"sector_#{s}_sb")
    end
  end

  def bike_position_json(bike_pos)
    {
      rider_number: bike_pos.rider.number,
      rider_acronym: bike_pos.rider.name_acronym,
      team_colour: bike_pos.rider.team.colour,
      x: bike_pos.x, y: bike_pos.y, z: bike_pos.z
    }
  end
end
