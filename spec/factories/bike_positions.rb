# frozen_string_literal: true

FactoryBot.define do
  factory :bike_position do
    session
    rider
    x { 1234.5 }
    y { 5678.9 }
    z { 0.0 }
    recorded_at { Time.current }
  end
end
