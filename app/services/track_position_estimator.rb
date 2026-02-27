# frozen_string_literal: true

class TrackPositionEstimator
  def initialize(circuit:)
    @circuit = circuit
    @coordinates = parse_coordinates
  end

  def estimate(timing_entries)
    return {} if @coordinates.empty? || timing_entries.empty?

    total_length = path_length
    return {} if total_length.zero?

    positions = {}

    timing_entries.each_with_index do |entry, index|
      fraction = spread_fraction(index, timing_entries.size, entry)
      point = point_at_fraction(fraction)
      positions[entry.rider_id] = point if point
    end

    positions
  end

  private

  def parse_coordinates
    return [] if @circuit.track_coordinates_json.blank?

    JSON.parse(@circuit.track_coordinates_json).map do |c|
      { x: (c['x'] || c[:x]).to_f, y: (c['y'] || c[:y]).to_f }
    end
  end

  def path_length
    total = 0.0
    (1...@coordinates.length).each do |i|
      dx = @coordinates[i][:x] - @coordinates[i - 1][:x]
      dy = @coordinates[i][:y] - @coordinates[i - 1][:y]
      total += Math.sqrt((dx * dx) + (dy * dy))
    end
    total
  end

  def spread_fraction(index, total, entry)
    gap = parse_gap(entry.gap_to_leader)
    if gap && gap > 0
      [gap / 90.0, 0.95].min
    else
      index.to_f / [total, 1].max
    end
  end

  def parse_gap(gap_str)
    return 0.0 if gap_str.blank? || gap_str == '0.000' || gap_str == '0'

    clean = gap_str.to_s.delete('+').strip
    Float(clean)
  rescue ArgumentError, TypeError
    nil
  end

  def point_at_fraction(fraction)
    return @coordinates.first if fraction <= 0
    return @coordinates.last if fraction >= 1

    target = fraction * path_length
    cumulative = 0.0

    (1...@coordinates.length).each do |i|
      dx = @coordinates[i][:x] - @coordinates[i - 1][:x]
      dy = @coordinates[i][:y] - @coordinates[i - 1][:y]
      segment_len = Math.sqrt((dx * dx) + (dy * dy))

      if cumulative + segment_len >= target
        remaining = target - cumulative
        t = segment_len.zero? ? 0 : remaining / segment_len
        return {
          x: @coordinates[i - 1][:x] + (t * dx),
          y: @coordinates[i - 1][:y] + (t * dy)
        }
      end

      cumulative += segment_len
    end

    @coordinates.last
  end
end
