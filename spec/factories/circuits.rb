# frozen_string_literal: true

FactoryBot.define do
  factory :circuit do
    sequence(:api_uuid) { |n| "circuit-uuid-#{n}" }
    sequence(:name) { |n| "Circuit #{n}" }
    short_name { 'Losail' }
    country { 'Qatar' }
    country_iso { 'QA' }
  end
end
