# frozen_string_literal: true

module Sync
  class TimingSync
    def initialize(client: MotoGpClient.new)
      @client = client
    end

    def call(session:)
      result = @client.classification(session_uuid: session.api_uuid)
      classifications = result.is_a?(Hash) ? (result['classification'] || []) : result

      riders = Rider.all.index_by(&:number)
      all_entries = TimingEntry.where(session: session).to_a

      classifications.each do |c|
        rider_data = c['rider']
        next unless rider_data

        rider = riders[rider_data['number']]
        next unless rider

        entry = TimingEntry.find_or_initialize_by(session: session, rider: rider)
        entry.assign_attributes(
          position: c['position'],
          gap_to_leader: format_gap(c['gap']),
          interval: format_gap(c['gap']),
          last_lap_time: format_time(c.dig('bestLap', 'time')),
          best_lap_time: format_time(c.dig('bestLap', 'time')),
          best_lap_number: c.dig('bestLap', 'number'),
          total_laps: c['totalLaps'],
          top_speed: c['topSpeed'],
          speed_trap: c['topSpeed'],
          status: c['status'],
          pit_stop_count: c['pitStops'] || 0
        )
        compute_personal_and_session_bests(entry, all_entries)
        entry.save!
      end
    end

    private

    def format_gap(gap_data)
      return nil if gap_data.nil?
      return gap_data.to_s if gap_data.is_a?(String)

      if gap_data.is_a?(Hash)
        gap_data['first'] || gap_data['lap'] || gap_data.to_s
      else
        gap_data.to_s
      end
    end

    def format_time(time_str)
      return nil if time_str.blank?

      time_str.to_s
    end

    def compute_personal_and_session_bests(entry, all_entries)
      other_entries = all_entries.reject { |e| e.rider_id == entry.rider_id }

      (1..3).each do |sector|
        current = parse_sector(entry.send(:"sector_#{sector}_time"))
        session_best = other_entries.filter_map { |e| parse_sector(e.send(:"sector_#{sector}_time")) }.min

        entry.send(:"sector_#{sector}_pb=", false)
        entry.send(:"sector_#{sector}_sb=", current.present? && (session_best.nil? || current <= session_best))
      end
    end

    def parse_sector(time_str)
      return nil if time_str.blank?

      time_str.to_f
    end
  end
end
