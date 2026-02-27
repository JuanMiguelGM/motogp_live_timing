# frozen_string_literal: true

module Sync
  class EventsSync
    def initialize(client: MotoGpClient.new)
      @client = client
    end

    def call(season:)
      api_events = @client.events(season_uuid: season.api_uuid)

      api_events.each do |api_event|
        circuit = find_or_create_circuit(api_event)
        find_or_update_event(api_event, season, circuit)
      end
    end

    private

    def find_or_create_circuit(api_event)
      circuit_data = api_event['circuit']
      return Circuit.find_or_create_by!(api_uuid: 'unknown', name: 'Unknown') unless circuit_data

      Circuit.find_or_initialize_by(api_uuid: circuit_data['id']).tap do |c|
        c.name = circuit_data['name'] || api_event['name']
        c.country = circuit_data.dig('country', 'name')
        c.country_iso = circuit_data.dig('country', 'iso')
        c.save!
      end
    end

    def find_or_update_event(api_event, season, circuit)
      event = Event.find_or_initialize_by(api_uuid: api_event['id'])
      event.assign_attributes(
        name: api_event['name'] || api_event['shortName'],
        official_name: api_event['name'],
        start_date: api_event['dateFrom']&.to_date,
        end_date: api_event['dateTo']&.to_date,
        finished: api_event['status'] == 'FINISHED',
        season: season,
        circuit: circuit
      )
      event.save!
      event
    end
  end
end
