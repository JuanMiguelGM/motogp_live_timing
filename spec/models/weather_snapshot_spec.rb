# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeatherSnapshot do
  describe 'associations' do
    it { is_expected.to belong_to(:session) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:recorded_at) }
  end

  describe 'scopes' do
    it '.latest returns the most recent snapshot' do
      session = create(:session)
      create(:weather_snapshot, session: session, recorded_at: 2.hours.ago)
      recent = create(:weather_snapshot, session: session, recorded_at: 1.hour.ago)

      expect(described_class.latest.first).to eq(recent)
    end
  end

  describe 'factory' do
    it 'creates a valid weather snapshot' do
      expect(build(:weather_snapshot)).to be_valid
    end
  end
end
