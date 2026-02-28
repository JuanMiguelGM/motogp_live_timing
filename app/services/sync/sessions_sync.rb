# frozen_string_literal: true

module Sync
  class SessionsSync
    # MotoGP API returns local circuit times mislabeled as +00:00.
    # Map circuit country ISO to IANA timezone for correct UTC conversion.
    CIRCUIT_TIMEZONES = {
      'QA' => 'Asia/Qatar',
      'PT' => 'Europe/Lisbon',
      'AR' => 'America/Argentina/Buenos_Aires',
      'ES' => 'Europe/Madrid',
      'FR' => 'Europe/Paris',
      'IT' => 'Europe/Rome',
      'HU' => 'Europe/Budapest',
      'CZ' => 'Europe/Prague',
      'NL' => 'Europe/Amsterdam',
      'DE' => 'Europe/Berlin',
      'GB' => 'Europe/London',
      'AT' => 'Europe/Vienna',
      'JP' => 'Asia/Tokyo',
      'ID' => 'Asia/Makassar',
      'AU' => 'Australia/Melbourne',
      'MY' => 'Asia/Kuala_Lumpur',
      'TH' => 'Asia/Bangkok',
      'US' => 'America/Chicago',
      'BR' => 'America/Sao_Paulo',
      'SM' => 'Europe/Rome'
    }.freeze

    def initialize(client: MotoGpClient.new)
      @client = client
    end

    def call(event:, category:)
      api_sessions = @client.sessions(event_uuid: event.api_uuid, category_uuid: category.api_uuid)
      circuit_tz = circuit_timezone(event)

      api_sessions.map { |api_session| sync_session(api_session, event, category, circuit_tz) }
    end

    private

    def sync_session(api_session, event, category, circuit_tz)
      session = Session.find_or_initialize_by(api_uuid: api_session['id'])
      session.assign_attributes(
        session_type: api_session['type'] || api_session['name'],
        status: determine_status(api_session, circuit_tz),
        start_date: parse_local_time(api_session['date'], circuit_tz),
        end_date: parse_local_time(api_session['dateEnd'], circuit_tz),
        event: event,
        category: category
      )
      assign_weather(session, api_session['condition'])
      session.save!
      session
    end

    def assign_weather(session, condition)
      return unless condition

      session.weather_condition = condition['name']
      session.air_temperature = condition['airTemperature']
      session.track_temperature = condition['trackTemperature']
      session.humidity = condition['humidity']
    end

    def circuit_timezone(event)
      country_iso = event.circuit&.country_iso
      tz_name = CIRCUIT_TIMEZONES[country_iso]
      tz_name ? ActiveSupport::TimeZone[tz_name] : Time.zone
    end

    def parse_local_time(date_str, circuit_tz)
      return nil if date_str.blank?

      # Strip the misleading +00:00 offset and parse as circuit-local time
      naive = date_str.sub(/[+-]\d{2}:\d{2}$/, '').sub(/Z$/, '')
      circuit_tz.parse(naive).utc
    end

    def determine_status(api_session, circuit_tz)
      return 'finished' if api_session['status'] == 'FINISHED' || api_session['hasResults']

      start_time = parse_local_time(api_session['date'], circuit_tz)
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
