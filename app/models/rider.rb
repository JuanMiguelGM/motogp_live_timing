# frozen_string_literal: true

class Rider < ApplicationRecord
  belongs_to :team

  has_many :timing_entries, dependent: :destroy
  has_many :bike_positions, dependent: :destroy

  validates :number, presence: true
  validates :full_name, presence: true
  validates :name_acronym, presence: true
end
