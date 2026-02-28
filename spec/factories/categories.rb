# frozen_string_literal: true

FactoryBot.define do
  factory :category do
    name { 'MotoGP' }
    sequence(:api_uuid) { |n| "category-uuid-#{n}" }
  end
end
