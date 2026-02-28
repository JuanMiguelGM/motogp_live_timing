# frozen_string_literal: true

FactoryBot.define do
  factory :race_direction_message do
    session
    category { 'Flag' }
    flag { 'GREEN' }
    scope { 'Track' }
    message { 'GREEN FLAG - RACE RESUMED' }
    recorded_at { Time.current }
  end
end
