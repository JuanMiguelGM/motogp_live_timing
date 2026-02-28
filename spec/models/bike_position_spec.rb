# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BikePosition do
  describe 'associations' do
    it { is_expected.to belong_to(:session) }
    it { is_expected.to belong_to(:rider) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:x) }
    it { is_expected.to validate_presence_of(:y) }
  end

  describe 'factory' do
    it 'creates a valid bike position' do
      expect(build(:bike_position)).to be_valid
    end
  end
end
