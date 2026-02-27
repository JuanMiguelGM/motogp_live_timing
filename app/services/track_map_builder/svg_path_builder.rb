# frozen_string_literal: true

class TrackMapBuilder
  class SvgPathBuilder
    ALPHA = 0.5

    def initialize(points)
      @points = points
    end

    def build
      return '' if @points.length < 2

      segments = catmull_rom_to_bezier
      return '' if segments.empty?

      parts = ["M #{@points.first[:x].round(1)},#{@points.first[:y].round(1)}"]
      segments.each do |seg|
        parts << "C #{seg[:cp1x].round(1)},#{seg[:cp1y].round(1)} " \
                 "#{seg[:cp2x].round(1)},#{seg[:cp2y].round(1)} " \
                 "#{seg[:x].round(1)},#{seg[:y].round(1)}"
      end
      parts << 'Z'
      parts.join(' ')
    end

    private

    def catmull_rom_to_bezier
      count = @points.length
      count.times.map do |i|
        compute_segment(
          @points[(i - 1) % count],
          @points[i],
          @points[(i + 1) % count],
          @points[(i + 2) % count]
        )
      end
    end

    def compute_segment(pt0, pt1, pt2, pt3)
      d1a = safe_distance(pt0, pt1)**ALPHA
      d2a = safe_distance(pt1, pt2)**ALPHA
      d3a = safe_distance(pt2, pt3)**ALPHA

      cp1x = compute_control_point(d1a, d2a, pt0[:x], pt1[:x], pt2[:x])
      cp1y = compute_control_point(d1a, d2a, pt0[:y], pt1[:y], pt2[:y])
      cp2x = compute_control_point_end(d3a, d2a, pt1[:x], pt2[:x], pt3[:x])
      cp2y = compute_control_point_end(d3a, d2a, pt1[:y], pt2[:y], pt3[:y])

      { cp1x: cp1x, cp1y: cp1y, cp2x: cp2x, cp2y: cp2y, x: pt2[:x], y: pt2[:y] }
    end

    def compute_control_point(d_alpha, d_beta, val_prev, val_curr, val_next)
      numerator = ((d_alpha**2) * val_next) - ((d_beta**2) * val_prev) +
                  (((2 * (d_alpha**2)) + (3 * d_alpha * d_beta) + (d_beta**2)) * val_curr)
      numerator / (3 * d_alpha * (d_alpha + d_beta))
    end

    def compute_control_point_end(d_alpha, d_beta, val_prev, val_curr, val_next)
      numerator = ((d_alpha**2) * val_prev) - ((d_beta**2) * val_next) +
                  (((2 * (d_alpha**2)) + (3 * d_alpha * d_beta) + (d_beta**2)) * val_curr)
      numerator / (3 * d_alpha * (d_alpha + d_beta))
    end

    def safe_distance(point_a, point_b)
      dist = Geometry.distance(point_a, point_b)
      dist.zero? ? 1.0 : dist
    end
  end
end
