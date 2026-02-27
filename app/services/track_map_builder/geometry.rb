# frozen_string_literal: true

class TrackMapBuilder
  module Geometry
    module_function

    def distance(point_a, point_b)
      dx = point_a[:x] - point_b[:x]
      dy = point_a[:y] - point_b[:y]
      Math.sqrt((dx**2) + (dy**2))
    end

    def extent(points)
      xs = points.pluck(:x)
      ys = points.pluck(:y)
      diagonal = Math.sqrt(((xs.max - xs.min)**2) + ((ys.max - ys.min)**2))
      [diagonal, 1.0].max
    end

    def perpendicular_distance(point, line_start, line_end)
      proj = project_onto_segment(point, line_start, line_end)
      return distance(point, line_start) unless proj

      Math.sqrt(((point[:x] - proj[:x])**2) + ((point[:y] - proj[:y])**2))
    end

    def project_onto_segment(point, line_start, line_end)
      dx = line_end[:x] - line_start[:x]
      dy = line_end[:y] - line_start[:y]
      len_sq = (dx * dx) + (dy * dy)
      return nil if len_sq.zero?

      raw_t = (((point[:x] - line_start[:x]) * dx) + ((point[:y] - line_start[:y]) * dy)) / len_sq
      clamped_t = raw_t.clamp(0.0, 1.0)

      { x: line_start[:x] + (clamped_t * dx), y: line_start[:y] + (clamped_t * dy) }
    end
  end
end
