# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RaceDirectionMessage do
  describe 'associations' do
    it { is_expected.to belong_to(:session) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:message) }
    it { is_expected.to validate_presence_of(:recorded_at) }
  end

  describe 'scopes' do
    let(:session) { create(:session) }

    it '.by_time orders by recorded_at descending' do
      old = create(:race_direction_message, session: session, recorded_at: 2.hours.ago)
      recent = create(:race_direction_message, session: session, recorded_at: 1.hour.ago)

      expect(described_class.by_time).to eq([recent, old])
    end

    it '.flags_only returns only messages with Flag category' do
      flagged = create(:race_direction_message, session: session, category: 'Flag', flag: 'YELLOW')
      create(:race_direction_message, session: session, category: 'Penalty', flag: nil)

      expect(described_class.flags_only).to contain_exactly(flagged)
    end
  end

  describe 'factory' do
    it 'creates a valid race direction message' do
      expect(build(:race_direction_message)).to be_valid
    end
  end
end
