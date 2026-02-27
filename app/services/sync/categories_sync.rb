# frozen_string_literal: true

module Sync
  class CategoriesSync
    def initialize(client: MotoGpClient.new)
      @client = client
    end

    def call(season:)
      api_categories = @client.categories(season_uuid: season.api_uuid)

      api_categories.map do |cat|
        category = Category.find_or_initialize_by(api_uuid: cat['id'])
        category.assign_attributes(
          name: cat['name'],
          legacy_id: cat['legacyId']
        )
        category.save!
        category
      end
    end
  end
end
