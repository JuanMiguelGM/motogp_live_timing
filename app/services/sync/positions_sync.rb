# frozen_string_literal: true

module Sync
  class PositionsSync
    def initialize(client: MotoGpClient.new)
      @client = client
    end

    def call(session:)
      circuit = session.event&.circuit
      return unless circuit&.track_coordinates_json.present?

      entries = session.timing_entries.includes(rider: :team).by_position
      return if entries.empty?

      TrackPositionEstimator.new(circuit: circuit).estimate(entries).each do |rider_id, position|
        bike_pos = BikePosition.find_or_initialize_by(session: session, rider_id: rider_id)
        bike_pos.assign_attributes(x: position[:x], y: position[:y], z: 0.0, recorded_at: Time.current)
        bike_pos.save!
      end
    end
  end
end
