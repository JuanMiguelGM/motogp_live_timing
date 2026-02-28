# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Session do
  describe 'associations' do
    it { is_expected.to belong_to(:event) }
    it { is_expected.to belong_to(:category).optional }
    it { is_expected.to have_many(:timing_entries).dependent(:destroy) }
    it { is_expected.to have_many(:bike_positions).dependent(:destroy) }
    it { is_expected.to have_many(:race_direction_messages).dependent(:destroy) }
    it { is_expected.to have_many(:weather_snapshots).dependent(:destroy) }
  end

  describe 'scopes' do
    let!(:live_session) { create(:session, status: 'live') }
    let!(:finished_session) { create(:session, status: 'finished') }
    let!(:upcoming_session) { create(:session, status: 'upcoming', start_date: 1.day.from_now) }

    it '.live returns sessions with live status' do
      expect(described_class.live).to contain_exactly(live_session)
    end

    it '.finished returns sessions with finished status' do
      expect(described_class.finished).to contain_exactly(finished_session)
    end

    it '.upcoming returns sessions with upcoming status' do
      expect(described_class.upcoming).to contain_exactly(upcoming_session)
    end

    it '.by_date orders by start_date descending' do
      expect(described_class.by_date.first).to eq(upcoming_session)
    end
  end

  describe 'factory' do
    it 'creates a valid session' do
      expect(build(:session)).to be_valid
    end
  end
end
