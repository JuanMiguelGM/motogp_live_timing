# frozen_string_literal: true

class BikePosition < ApplicationRecord
  belongs_to :session
  belongs_to :rider

  validates :rider_id, uniqueness: { scope: :session_id }
  validates :x, presence: true
  validates :y, presence: true
end
