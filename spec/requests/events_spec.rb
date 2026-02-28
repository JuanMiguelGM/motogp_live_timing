# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Events' do
  describe 'GET /events' do
    it 'renders the calendar index' do
      season = create(:season, year: Time.current.year, current: true)
      create(:event, season: season, name: 'Qatar Grand Prix')

      get events_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Qatar Grand Prix')
      expect(response.body).to include('MotoGP Calendar')
    end

    it 'filters by year param' do
      past_season = create(:season, year: 2024)
      create(:event, season: past_season, name: 'Qatar 2024')

      get events_path(year: 2024)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Qatar 2024')
    end
  end

  describe 'GET /events/:id' do
    it 'renders the event show page with sessions' do
      event = create(:event, name: 'Italian Grand Prix')
      create(:session, event: event, session_type: 'RAC', status: 'finished')
      create(:session, event: event, session_type: 'QP', status: 'finished')

      get event_path(event)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Italian Grand Prix')
      expect(response.body).to include('RAC')
      expect(response.body).to include('QP')
    end
  end
end
