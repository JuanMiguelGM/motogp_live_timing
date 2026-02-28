# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Season do
  describe 'associations' do
    it { is_expected.to have_many(:events) }
  end

  describe 'validations' do
    it 'validates uniqueness of year' do
      create(:season, year: 2025)
      expect(build(:season, year: 2025)).not_to be_valid
    end
  end

  describe 'scopes' do
    it '.current_season returns the season marked current' do
      create(:season, year: 2024, current: false)
      current = create(:season, year: 2025, current: true)

      expect(described_class.current_season).to eq(current)
    end
  end

  describe 'factory' do
    it 'creates a valid season' do
      expect(build(:season)).to be_valid
    end
  end
end
