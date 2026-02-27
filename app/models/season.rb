# frozen_string_literal: true

class Season < ApplicationRecord
  has_many :events, dependent: :destroy

  validates :year, presence: true, uniqueness: true

  scope :current_season, -> { find_by(current: true) }
end
