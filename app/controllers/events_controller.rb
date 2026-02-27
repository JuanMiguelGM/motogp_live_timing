# frozen_string_literal: true

class EventsController < ApplicationController
  def index
    @season = Season.find_by(year: params[:year] || Time.current.year)
    @events = if @season
                @season.events.includes(:circuit, sessions: { timing_entries: { rider: :team } }).order(:start_date)
              else
                Event.none
              end
  end

  def show
    @event = Event.includes(:circuit, sessions: { timing_entries: { rider: :team } }).find(params[:id])
    @sessions = @event.sessions.sort_by { |s| s.start_date || Time.zone.at(0) }
  end
end
