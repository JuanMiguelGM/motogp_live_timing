# frozen_string_literal: true

module Api
  class SessionStatusController < ApplicationController
    def show
      live_session = Session.live.includes(event: :circuit).order(start_date: :desc).first

      if live_session
        render json: {
          live: true,
          session_id: live_session.id,
          session_type: live_session.session_type,
          event_name: live_session.event&.name
        }
      else
        next_session = Session.upcoming.includes(event: :circuit).order(start_date: :asc).first

        render json: {
          live: false,
          next_session_id: next_session&.id,
          next_session_start: next_session&.start_date&.iso8601,
          next_session_type: next_session&.session_type,
          next_event_name: next_session&.event&.name
        }
      end
    end
  end
end
