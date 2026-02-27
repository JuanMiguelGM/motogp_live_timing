# frozen_string_literal: true

class Session < ApplicationRecord
  belongs_to :event
  belongs_to :category, optional: true

  has_many :timing_entries, dependent: :destroy
  has_many :bike_positions, dependent: :destroy
  has_many :race_direction_messages, dependent: :destroy
  has_many :weather_snapshots, dependent: :destroy

  validates :api_uuid, presence: true, uniqueness: true
  validates :session_type, presence: true

  scope :live, -> { where(status: 'live') }
  scope :finished, -> { where(status: 'finished') }
  scope :upcoming, -> { where(status: 'upcoming') }
  scope :by_date, -> { order(start_date: :desc) }
end
