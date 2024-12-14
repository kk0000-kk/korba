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

    def deg_to_rad(deg)
      rad = deg * Math::PI / 180.0
      normalize_rad(rad)
    end

    def normalize_rad(rad)
      rad = rad + 2 * Math::PI if rad < 0
      normalize_rad = rad > 2 * Math::PI ? rad - 2 * Math::PI : rad
      normalize_rad(normalize_rad) if normalize_rad != rad
      normalize_rad
    end

    def rad_to_deg(rad)
      deg = rad * 180.0 / Math::PI
      normalize_deg(deg)
    end

    def normalize_deg(deg)
      deg = deg + 360 if deg < 0
      normalized_deg = deg > 360 ? deg - 360 : deg
      normalize_deg(normalized_deg) if normalized_deg != deg
      normalized_deg
    end
  end
end
