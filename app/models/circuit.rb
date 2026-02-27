# frozen_string_literal: true

class Circuit < ApplicationRecord
  has_many :events, dependent: :destroy

  validates :name, presence: true
  validates :api_uuid, presence: true, uniqueness: true
end
