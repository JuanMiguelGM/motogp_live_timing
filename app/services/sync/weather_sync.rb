# frozen_string_literal: true

module Sync
  class WeatherSync
    def initialize(client: MotoGpClient.new)
      @client = client
    end

    def call(session:)
      return unless session.air_temperature

      existing = session.weather_snapshots.order(recorded_at: :desc).first
      return if existing && existing.recorded_at >= 1.minute.ago

      session.weather_snapshots.create!(
        air_temperature: session.air_temperature,
        track_temperature: session.track_temperature,
        humidity: session.humidity,
        recorded_at: Time.current
      )
    end
  end
end
