# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Category do
  describe 'associations' do
    it { is_expected.to have_many(:sessions) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }

    it 'validates uniqueness of api_uuid' do
      create(:category)
      expect(build(:category, api_uuid: described_class.last.api_uuid)).not_to be_valid
    end
  end

  describe 'factory' do
    it 'creates a valid category' do
      expect(build(:category)).to be_valid
    end
  end
end
