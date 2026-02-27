# frozen_string_literal: true

class RaceDirectionMessage < ApplicationRecord
  belongs_to :session

  validates :message, presence: true
  validates :recorded_at, presence: true

  scope :by_time, -> { order(recorded_at: :desc) }
  scope :flags_only, -> { where(category: 'Flag') }
end
