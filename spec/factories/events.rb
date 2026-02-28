# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    sequence(:api_uuid) { |n| "event-uuid-#{n}" }
    sequence(:name) { |n| "Grand Prix #{n}" }
    official_name { "MOTOGP #{name.upcase}" }
    start_date { Date.current }
    end_date { Date.current + 2 }
    finished { false }
    season
    circuit
  end
end
