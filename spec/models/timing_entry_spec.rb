# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TimingEntry do
  describe 'associations' do
    it { is_expected.to belong_to(:session) }
    it { is_expected.to belong_to(:rider) }
  end

  describe 'scopes' do
    it '.by_position orders by position ascending' do
      session = create(:session)
      rider1 = create(:rider)
      rider2 = create(:rider)
      entry2 = create(:timing_entry, session: session, rider: rider2, position: 2)
      entry1 = create(:timing_entry, session: session, rider: rider1, position: 1)

      expect(described_class.by_position).to eq([entry1, entry2])
    end
  end

  describe 'factory' do
    it 'creates a valid timing entry' do
      expect(build(:timing_entry)).to be_valid
    end
  end
end
