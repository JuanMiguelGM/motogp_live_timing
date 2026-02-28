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
    if gap&.positive?
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
    walk_path_to(target)
  end

  def walk_path_to(target)
    cumulative = 0.0

    (1...@coordinates.length).each do |i|
      segment = segment_between(i - 1, i)
      return interpolate_point(i - 1, segment, target - cumulative) if cumulative + segment[:length] >= target

      cumulative += segment[:length]
    end

    @coordinates.last
  end

  def segment_between(from, to)
    dx = @coordinates[to][:x] - @coordinates[from][:x]
    dy = @coordinates[to][:y] - @coordinates[from][:y]
    { dx: dx, dy: dy, length: Math.sqrt((dx * dx) + (dy * dy)) }
  end

  def interpolate_point(from_idx, segment, remaining)
    t = segment[:length].zero? ? 0 : remaining / segment[:length]
    {
      x: @coordinates[from_idx][:x] + (t * segment[:dx]),
      y: @coordinates[from_idx][:y] + (t * segment[:dy])
    }
  end
end
