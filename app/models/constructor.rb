# frozen_string_literal: true

class Constructor < ApplicationRecord
  has_many :teams, dependent: :destroy

  validates :name, presence: true
  validates :api_uuid, uniqueness: true, allow_nil: true
end
