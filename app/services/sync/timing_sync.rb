# frozen_string_literal: true

module Sync
  class TimingSync
    def initialize(client: MotoGpClient.new)
      @client = client
    end

    def call(session:)
      classifications = fetch_classifications(session)
      riders = Rider.all.index_by(&:number)
      all_entries = TimingEntry.where(session: session).to_a

      classifications.each do |c|
        rider = find_rider(c, riders)
        next unless rider

        entry = TimingEntry.find_or_initialize_by(session: session, rider: rider)
        entry.assign_attributes(entry_attributes(c))
        compute_personal_and_session_bests(entry, all_entries)
        entry.save!
      end
    end

    private

    def fetch_classifications(session)
      result = @client.classification(session_uuid: session.api_uuid)
      result.is_a?(Hash) ? (result['classification'] || []) : result
    end

    def find_rider(classification, riders)
      rider_data = classification['rider']
      return nil unless rider_data

      riders[rider_data['number']]
    end

    def entry_attributes(classification)
      gap_data = classification['gap']
      best_lap_time = classification.dig('best_lap', 'time')
      race_time = classification['time']

      {
        position: classification['position'],
        gap_to_leader: format_gap_to_leader(gap_data),
        interval: format_interval_gap(gap_data),
        last_lap_time: format_time(best_lap_time || race_time),
        best_lap_time: format_time(best_lap_time || race_time),
        best_lap_number: classification.dig('best_lap', 'number'),
        total_laps: classification['total_laps'],
        top_speed: classification['top_speed'] || classification['average_speed'],
        speed_trap: classification['top_speed'] || classification['average_speed'],
        status: classification['status'],
        pit_stop_count: classification['pit_stops'] || 0
      }
    end

    def format_gap_to_leader(gap_data)
      return nil if gap_data.nil?
      return gap_data.to_s if gap_data.is_a?(String)

      gap_data.is_a?(Hash) ? gap_data['first'] : gap_data.to_s
    end

    def format_interval_gap(gap_data)
      return nil if gap_data.nil?
      return gap_data.to_s if gap_data.is_a?(String)

      gap_data.is_a?(Hash) ? gap_data['prev'] : gap_data.to_s
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
