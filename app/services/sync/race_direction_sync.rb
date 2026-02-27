# frozen_string_literal: true

module Sync
  class RaceDirectionSync
    def initialize(client: MotoGpClient.new)
      @client = client
    end

    def call(session:)
      # MotoGP API doesn't have a separate race direction endpoint
      # Messages are typically embedded in session data or websocket feeds
    end
  end
end
