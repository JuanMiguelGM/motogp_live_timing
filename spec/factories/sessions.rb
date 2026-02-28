# frozen_string_literal: true

FactoryBot.define do
  factory :session do
    sequence(:api_uuid) { |n| "session-uuid-#{n}" }
    session_type { 'RAC' }
    status { 'finished' }
    start_date { 2.hours.ago }
    end_date { 1.hour.ago }
    event
    category
  end
end
