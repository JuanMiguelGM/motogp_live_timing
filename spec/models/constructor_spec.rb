# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Constructor do
  describe 'associations' do
    it { is_expected.to have_many(:teams) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }

    it 'validates uniqueness of api_uuid' do
      create(:constructor)
      expect(build(:constructor, api_uuid: described_class.last.api_uuid)).not_to be_valid
    end
  end

  describe 'factory' do
    it 'creates a valid constructor' do
      expect(build(:constructor)).to be_valid
    end
  end
end
