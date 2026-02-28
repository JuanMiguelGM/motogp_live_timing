# frozen_string_literal: true

FactoryBot.define do
  factory :rider do
    sequence(:number) { |n| n }
    sequence(:full_name) { |n| "Rider #{n}" }
    sequence(:name_acronym) { |n| "R#{format('%02d', n)}" }
    sequence(:api_uuid) { |n| "rider-uuid-#{n}" }
    country_iso { 'ES' }
    team
  end
end
