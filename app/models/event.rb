# frozen_string_literal: true

class Event < ApplicationRecord
  belongs_to :season
  belongs_to :circuit

  has_many :sessions, dependent: :destroy

  validates :name, presence: true
  validates :api_uuid, presence: true, uniqueness: true
end
