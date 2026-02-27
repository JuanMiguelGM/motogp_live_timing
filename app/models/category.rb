# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :sessions, dependent: :destroy

  validates :name, presence: true
  validates :api_uuid, uniqueness: true, allow_nil: true
end
