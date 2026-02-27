# frozen_string_literal: true

class DashboardController < ApplicationController
  def show
    @session = find_live_session

    if @session
      load_live_session_data
    else
      load_off_session_data
    end
  end

  private

  def find_live_session
    Session.live.includes(event: :circuit).order(start_date: :desc).first
  end

  def load_live_session_data
    @event = @session.event
    @timing_entries = @session.timing_entries.includes(rider: :team).by_position
    @bike_positions = @session.bike_positions.includes(rider: :team)
    @weather = @session.weather_snapshots.latest.first
    @race_direction_messages = @session.race_direction_messages.by_time.limit(20)
  end

  def load_off_session_data
    @last_session = Session.finished.includes(event: :circuit).order(start_date: :desc).first
    @next_session = Session.upcoming.includes(event: :circuit).order(start_date: :asc).first

    @last_results = @last_session.timing_entries.includes(rider: :team).by_position.limit(10) if @last_session

    @timing_entries = TimingEntry.none
    @bike_positions = BikePosition.none
  end
end
