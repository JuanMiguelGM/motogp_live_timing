# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Session Status' do
  describe 'GET /api/session_status' do
    context 'with a live session' do
      it 'returns live status with session info' do
        session = create(:session, status: 'live')

        get api_session_status_path, as: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['live']).to be true
        expect(json['session_id']).to eq(session.id)
        expect(json['event_name']).to eq(session.event.name)
      end
    end

    context 'without a live session' do
      it 'returns not live with next session info' do
        next_session = create(:session, status: 'upcoming', start_date: 1.day.from_now)

        get api_session_status_path, as: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['live']).to be false
        expect(json['next_session_id']).to eq(next_session.id)
      end
    end

    context 'with no sessions at all' do
      it 'returns not live with nil next session' do
        get api_session_status_path, as: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['live']).to be false
        expect(json['next_session_id']).to be_nil
      end
    end
  end
end
