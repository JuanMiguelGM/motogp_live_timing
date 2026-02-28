# frozen_string_literal: true

class TrackMapBuilder
  MIN_LAP_POINTS = 10
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
      entry = find_seed_entry(seed_data, circuit)
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

    circuit = Circuit.find_by(api_uuid: circuit_api_uuid)
    entry = circuit ? self.class.find_seed_entry(seed_data, circuit) : seed_data[circuit_api_uuid.to_s]
    return nil unless entry

    entry['points'].map { |p| { x: p['x'].to_f, y: p['y'].to_f } }
  end

  def self.find_seed_entry(seed_data, circuit)
    circuit_name = circuit.name&.downcase || ''
    # Match by key (short name), api_uuid, or fuzzy name match
    seed_data[circuit.short_name&.downcase] ||
      seed_data[circuit.api_uuid.to_s] ||
      seed_data.find { |_key, entry|
        entry_name = entry['name']&.downcase || ''
        fuzzy_circuit_match?(circuit_name, entry_name)
      }&.last
  end

  def self.fuzzy_circuit_match?(circuit_name, seed_name)
    return false if circuit_name.blank? || seed_name.blank?

    # Direct substring match in either direction
    return true if circuit_name.include?(seed_name) || seed_name.include?(circuit_name)

    # Normalize accents and special chars for comparison
    normalized_circuit = circuit_name.gsub(/[áàäâ]/, 'a').gsub(/[éèëê]/, 'e').gsub(/[íìïî]/, 'i')
                                     .gsub(/[óòöô]/, 'o').gsub(/[úùüû]/, 'u').gsub(/ñ/, 'n')
    normalized_seed = seed_name.gsub(/[áàäâ]/, 'a').gsub(/[éèëê]/, 'e').gsub(/[íìïî]/, 'i')
                               .gsub(/[óòöô]/, 'o').gsub(/[úùüû]/, 'u').gsub(/ñ/, 'n')

    return true if normalized_circuit.include?(normalized_seed) || normalized_seed.include?(normalized_circuit)

    # Check significant shared keywords (3+ chars)
    circuit_words = normalized_circuit.scan(/[a-z]{3,}/)
    seed_words = normalized_seed.scan(/[a-z]{3,}/)
    (circuit_words & seed_words).length >= 2
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
