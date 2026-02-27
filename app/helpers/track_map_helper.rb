# frozen_string_literal: true

module TrackMapHelper
  def track_map_bounds(coordinates)
    return { width: 900, height: 900 } if coordinates.empty?

    xs = coordinates.map { |c| c['x'] || c[:x] }
    ys = coordinates.map { |c| c['y'] || c[:y] }

    {
      width: (xs.max.to_f + 100).ceil,
      height: (ys.max.to_f + 100).ceil
    }
  end

  def normalize_bike_position(bike_position, circuit)
    return nil if circuit.track_coordinates_json.blank?

    coordinates = JSON.parse(circuit.track_coordinates_json)
    return nil if coordinates.empty?

    bounds = raw_bounds_from_coordinates(coordinates)
    return nil if bounds[:scale].zero?

    padding = 50
    view_size = 800.0

    {
      x: padding + ((bike_position.x - bounds[:min_x]) / bounds[:scale] * view_size),
      y: padding + ((bike_position.y - bounds[:min_y]) / bounds[:scale] * view_size)
    }
  end

  private

  def raw_bounds_from_coordinates(coordinates)
    xs = coordinates.map { |c| c['x'] || c[:x] }
    ys = coordinates.map { |c| c['y'] || c[:y] }
    width = xs.max - xs.min
    height = ys.max - ys.min

    { min_x: xs.min, min_y: ys.min, scale: [width, height].max.to_f }
  end
end
