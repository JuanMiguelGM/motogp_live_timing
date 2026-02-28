# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event do
  describe 'associations' do
    it { is_expected.to belong_to(:season) }
    it { is_expected.to belong_to(:circuit) }
    it { is_expected.to have_many(:sessions).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }

    it 'validates uniqueness of api_uuid' do
      create(:event)
      expect(build(:event, api_uuid: described_class.last.api_uuid)).not_to be_valid
    end
  end

  describe 'factory' do
    it 'creates a valid event' do
      expect(build(:event)).to be_valid
    end
  end
end
