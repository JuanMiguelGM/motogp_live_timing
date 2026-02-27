# frozen_string_literal: true

class Team < ApplicationRecord
  belongs_to :constructor, optional: true
  has_many :riders, dependent: :destroy

  validates :name, presence: true
  validates :colour, presence: true
end
