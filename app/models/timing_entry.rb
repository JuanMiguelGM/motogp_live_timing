# frozen_string_literal: true

class TimingEntry < ApplicationRecord
  belongs_to :session
  belongs_to :rider

  validates :rider_id, uniqueness: { scope: :session_id }

  scope :by_position, -> { order(Arel.sql('position IS NULL, position ASC')) }
end
