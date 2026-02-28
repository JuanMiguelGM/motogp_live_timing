# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rider do
  describe 'associations' do
    it { is_expected.to belong_to(:team) }
    it { is_expected.to have_many(:timing_entries) }
    it { is_expected.to have_many(:bike_positions) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:number) }
    it { is_expected.to validate_presence_of(:full_name) }
    it { is_expected.to validate_presence_of(:name_acronym) }
  end

  describe 'factory' do
    it 'creates a valid rider' do
      expect(build(:rider)).to be_valid
    end
  end
end
