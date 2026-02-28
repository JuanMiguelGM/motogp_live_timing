# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Team do
  describe 'associations' do
    it { is_expected.to belong_to(:constructor).optional }
    it { is_expected.to have_many(:riders) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:colour) }
  end

  describe 'factory' do
    it 'creates a valid team' do
      expect(build(:team)).to be_valid
    end
  end
end
