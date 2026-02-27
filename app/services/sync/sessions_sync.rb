# frozen_string_literal: true

module Sync
  class SessionsSync
    def initialize(client: MotoGpClient.new)
      @client = client
    end

    def call(event:, category:)
      api_sessions = @client.sessions(event_uuid: event.api_uuid, category_uuid: category.api_uuid)

      api_sessions.map do |api_session|
        session = Session.find_or_initialize_by(api_uuid: api_session['id'])
        session.assign_attributes(
          session_type: api_session['type'] || api_session['name'],
          status: determine_status(api_session),
          start_date: api_session['date'],
          end_date: api_session['dateEnd'],
          event: event,
          category: category
        )

        if api_session['condition']
          session.weather_condition = api_session['condition']['name']
          session.air_temperature = api_session['condition']['airTemperature']
          session.track_temperature = api_session['condition']['trackTemperature']
          session.humidity = api_session['condition']['humidity']
        end

        session.save!
        session
      end
    end

    private

    def determine_status(api_session)
      return 'finished' if api_session['status'] == 'FINISHED' || api_session['hasResults']

      start_time = begin
        Time.zone.parse(api_session['date'])
      rescue StandardError
        nil
      end
      return 'upcoming' unless start_time

      now = Time.current
      if now < start_time
        'upcoming'
      elsif now > start_time + 2.hours
        'finished'
      else
        'live'
      end
    end
  end
end
