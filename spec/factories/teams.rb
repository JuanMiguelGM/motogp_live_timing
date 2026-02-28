# frozen_string_literal: true

FactoryBot.define do
  factory :team do
    sequence(:name) { |n| "Team #{n}" }
    colour { 'CC0000' }
    sequence(:api_uuid) { |n| "team-uuid-#{n}" }
    constructor
  end
end
