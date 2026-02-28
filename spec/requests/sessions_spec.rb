# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sessions' do
  describe 'GET /sessions/:id' do
    it 'renders the session view with timing and track map' do
      session = create(:session, status: 'finished')
      rider = create(:rider)
      create(:timing_entry, session: session, rider: rider, position: 1)

      get session_path(session)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(rider.name_acronym)
    end
  end

  describe 'GET /sessions/:id/timing_data' do
    it 'returns timing data as JSON' do
      session = create(:session)
      rider = create(:rider)
      create(:timing_entry, session: session, rider: rider, position: 1,
                            best_lap_time: '1:31.234')

      get timing_data_session_path(session), as: :json

      expect(response).to have_http_status(:ok)
      json = response.parsed_body
      expect(json).to be_an(Array)
      expect(json.first['rider_number']).to eq(rider.number)
    end
  end

  describe 'GET /sessions/:id/positions' do
    it 'returns position data as JSON' do
      session = create(:session)
      rider = create(:rider)
      create(:bike_position, session: session, rider: rider, x: 100.0, y: 200.0)

      get positions_session_path(session), as: :json

      expect(response).to have_http_status(:ok)
      json = response.parsed_body
      expect(json).to be_an(Array)
      expect(json.first['rider_number']).to eq(rider.number)
    end
  end
end
