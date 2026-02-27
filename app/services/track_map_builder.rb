# frozen_string_literal: true

class TrackMapBuilder
  MIN_LAP_POINTS = 100
  MAX_SIMPLIFIED_POINTS = 120

  SEED_FILE = Rails.root.join('db/track_coordinates.json')

  def initialize(client: MotoGpClient.new)
    @client = client
  end

  def call(session:, force: false)
    circuit = session.event.circuit
    return circuit if !force && circuit.track_coordinates_json.present?

    raw_points = load_seed_points(circuit.api_uuid)
    return circuit if raw_points.nil? || raw_points.length < MIN_LAP_POINTS

    build_track_map(circuit, raw_points)
  end

  def self.rebuild_all_from_seed
    seed_data = load_seed_file
    return if seed_data.nil?

    builder = new
    Circuit.find_each do |circuit|
      entry = seed_data[circuit.api_uuid.to_s] || seed_data[circuit.name]
      unless entry
        yield(:skip, circuit, 'no seed data') if block_given?
        next
      end

      points = entry['points'].map { |p| { x: p['x'].to_f, y: p['y'].to_f } }
      if points.length < MIN_LAP_POINTS
        yield(:skip, circuit, 'too few points') if block_given?
        next
      end

      builder.send(:build_track_map, circuit, points)
      yield(:ok, circuit, nil) if block_given?
    end
  end

  def self.load_seed_file
    return nil unless SEED_FILE.exist?

    JSON.parse(SEED_FILE.read)
  end

  private

  def build_track_map(circuit, raw_points)
    simplified = rdp_simplify(raw_points, adaptive_tolerance(raw_points))
    normalized = normalize_coordinates(simplified)

    circuit.update!(
      track_coordinates_json: normalized.to_json,
      svg_data: SvgPathBuilder.new(normalized).build
    )

    circuit
  end

  def load_seed_points(circuit_api_uuid)
    seed_data = self.class.load_seed_file
    return nil if seed_data.nil?

    entry = seed_data[circuit_api_uuid.to_s]
    return nil unless entry

    entry['points'].map { |p| { x: p['x'].to_f, y: p['y'].to_f } }
  end

  def rdp_simplify(points, epsilon)
    return points if points.length <= 2

    dmax = 0.0
    index = 0

    (1...(points.length - 1)).each do |i|
      dist = Geometry.perpendicular_distance(points[i], points.first, points.last)
      if dist > dmax
        dmax = dist
        index = i
      end
    end

    if dmax > epsilon
      left = rdp_simplify(points[0..index], epsilon)
      right = rdp_simplify(points[index..], epsilon)
      left[0...-1] + right
    else
      [points.first, points.last]
    end
  end

  def adaptive_tolerance(points)
    extent = Geometry.extent(points)
    low = extent * 0.001
    high = extent * 0.1

    10.times do
      mid = (low + high) / 2.0
      count = rdp_simplify(points, mid).length
      if count > MAX_SIMPLIFIED_POINTS
        low = mid
      else
        high = mid
      end
    end

    (low + high) / 2.0
  end

  def normalize_coordinates(coordinates)
    xs = coordinates.pluck(:x)
    ys = coordinates.pluck(:y)
    min_x = xs.min
    min_y = ys.min
    scale = [xs.max - min_x, ys.max - min_y].max
    return coordinates if scale.zero?

    padding = 50
    view_size = 800.0

    coordinates.map do |coord|
      {
        x: padding + ((coord[:x] - min_x).to_f / scale * view_size),
        y: padding + ((coord[:y] - min_y).to_f / scale * view_size)
      }
    end
  end
end
