# frozen_string_literal: true

require 'net/http'
require 'json'

class MotoGpClient
  BASE_URL = 'https://api.motogp.pulselive.com/motogp/v1'

  class ApiError < StandardError; end

  def seasons
    get('/results/seasons')
  end

  def events(season_uuid:)
    get("/results/events?seasonUuid=#{season_uuid}&isFinished=true") +
      get("/results/events?seasonUuid=#{season_uuid}&isFinished=false")
  end

  def categories(season_uuid:)
    get("/results/categories?seasonUuid=#{season_uuid}")
  end

  def sessions(event_uuid:, category_uuid:)
    get("/results/sessions?eventUuid=#{event_uuid}&categoryUuid=#{category_uuid}")
  end

  def classification(session_uuid:)
    get("/results/session/#{session_uuid}/classification")
  rescue ApiError
    { 'classification' => [] }
  end

  def entry_list(event_uuid:, category_uuid:)
    get("/results/entries?eventUuid=#{event_uuid}&categoryUuid=#{category_uuid}")
  rescue ApiError
    []
  end

  def teams(category_uuid:, season_year:)
    get("/teams?categoryUuid=#{category_uuid}&seasonYear=#{season_year}")
  rescue ApiError
    []
  end

  private

  def get(path)
    url = path.start_with?('http') ? path : "#{BASE_URL}#{path}"
    uri = URI(url)

    retries = 0
    loop do
      response = Net::HTTP.get_response(uri)

      if response.code == '429' && retries < 5
        retries += 1
        sleep(3 * retries)
        next
      end

      raise ApiError, "MotoGP API error: #{response.code} for #{path}" unless response.is_a?(Net::HTTPSuccess)

      return JSON.parse(response.body)
    end
  end
end
