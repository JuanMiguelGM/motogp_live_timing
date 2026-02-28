# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dashboard' do
  describe 'GET /' do
    context 'with a live session' do
      it 'renders the dashboard with timing data' do
        session = create(:session, status: 'live')
        rider = create(:rider)
        create(:timing_entry, session: session, rider: rider)

        get root_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('MotoGP LIVE TIMING')
      end
    end

    context 'without any live session' do
      it 'renders the off-session view' do
        get root_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('No Session Data')
      end
    end

    context 'with a finished and upcoming session' do
      it 'shows last results and next session countdown' do
        event = create(:event)
        create(:session, event: event, status: 'finished', start_date: 1.day.ago)
        create(:session, event: event, status: 'upcoming', start_date: 1.day.from_now, session_type: 'FP1')

        get root_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Last Session')
        expect(response.body).to include('Next Session')
      end
    end
  end
end
