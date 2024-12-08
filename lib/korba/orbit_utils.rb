# frozen_string_literal: true

module Korba
  module OrbitUtils
    def semi_major_axis
      # a = (μ / n^2)^(1/3) m
      (Korba::Constant::GME / (mean_motion * 2 * Math::PI / 86400.0) ** 2.0) ** (1.0 / 3.0)
    end

    def height_at_perigee
      semi_major_axis * (1 - eccentricity) - Korba::Constant::EARTH_RADIUS
    end

    def height_at_apogee
      semi_major_axis * (1 + eccentricity) - Korba::Constant::EARTH_RADIUS
    end
  end
end
