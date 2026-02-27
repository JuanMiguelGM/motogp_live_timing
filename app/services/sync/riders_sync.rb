# frozen_string_literal: true

module Sync
  class RidersSync
    def initialize(client: MotoGpClient.new)
      @client = client
    end

    def call(event:, category:)
      entries = @client.entry_list(event_uuid: event.api_uuid, category_uuid: category.api_uuid)

      entries.each do |entry|
        rider_data = entry['rider']
        next unless rider_data

        constructor = find_or_create_constructor(entry)
        team = find_or_create_team(entry, constructor)
        find_or_update_rider(rider_data, team)
      end
    end

    private

    def find_or_create_constructor(entry)
      constructor_data = entry['constructor']
      return nil unless constructor_data

      constructor = Constructor.find_or_initialize_by(name: constructor_data['name'])
      constructor.api_uuid = constructor_data['id'] if constructor_data['id']
      constructor.save!
      constructor
    end

    def find_or_create_team(entry, constructor)
      team_data = entry['team']
      team_name = team_data&.dig('name') || 'Independent'

      team = Team.find_or_initialize_by(name: team_name)
      team.colour = team_data&.dig('color')&.delete('#') || team_colour_fallback(constructor&.name)
      team.constructor = constructor if constructor
      team.api_uuid = team_data&.dig('id')
      team.save!
      team
    end

    def find_or_update_rider(rider_data, team)
      number = rider_data['number']
      return unless number

      rider = Rider.find_or_initialize_by(number: number)
      rider.assign_attributes(
        full_name: "#{rider_data['name']} #{rider_data['surname']}".strip,
        name_acronym: rider_data['surname']&.first(3)&.upcase || 'UNK',
        headshot_url: rider_data.dig('profilePicture', 'url'),
        api_uuid: rider_data['id'],
        legacy_id: rider_data['legacyId'],
        country_iso: rider_data.dig('country', 'iso'),
        team: team
      )
      rider.save!
      rider
    end

    def team_colour_fallback(constructor_name)
      {
        'Ducati' => 'CC0000',
        'Yamaha' => '0066CC',
        'Honda' => 'CC0000',
        'KTM' => 'FF6600',
        'Aprilia' => '000000',
        'GASGAS' => 'CC3333'
      }[constructor_name] || '888888'
    end
  end
end
