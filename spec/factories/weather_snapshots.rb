# frozen_string_literal: true

FactoryBot.define do
  factory :weather_snapshot do
    session
    air_temperature { 25.5 }
    track_temperature { 42.0 }
    humidity { 55.0 }
    pressure { 1013.0 }
    wind_speed { 3.2 }
    wind_direction { 180 }
    rainfall { 0 }
    recorded_at { Time.current }
  end
end
