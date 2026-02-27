# frozen_string_literal: true

class WeatherSnapshot < ApplicationRecord
  belongs_to :session

  validates :recorded_at, presence: true

  scope :latest, -> { order(recorded_at: :desc).limit(1) }
end
