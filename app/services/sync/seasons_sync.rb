# frozen_string_literal: true

module Sync
  class SeasonsSync
    def initialize(client: MotoGpClient.new)
      @client = client
    end

    def call(year:)
      api_seasons = @client.seasons
      api_season = api_seasons.find { |s| s['year'] == year }
      raise "Season #{year} not found in API" unless api_season

      season = Season.find_or_initialize_by(year: year)
      season.assign_attributes(
        api_uuid: api_season['id'],
        current: api_season['current'] || false
      )
      season.save!
      season
    end
  end
end
