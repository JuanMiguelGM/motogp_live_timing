# frozen_string_literal: true

FactoryBot.define do
  factory :season do
    sequence(:year) { |n| 2020 + n }
    sequence(:api_uuid) { |n| "season-uuid-#{n}" }
    current { false }
  end
end
