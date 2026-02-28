# frozen_string_literal: true

FactoryBot.define do
  factory :constructor do
    sequence(:name) { |n| "Constructor #{n}" }
    colour { 'CC0000' }
    sequence(:api_uuid) { |n| "constructor-uuid-#{n}" }
  end
end
