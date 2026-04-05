# frozen_string_literal: true

module Korba
  module OrbitUtils
    def semi_major_axis
      # a = (μ / n^2)^(1/3) m
      (Constant::GME / (mean_motion * 2.0 * Math::PI / 86400.0) ** 2.0) ** (1.0 / 3.0)
    end

    def height_at_perigee
      semi_major_axis * (1 - eccentricity) - Constant::EARTH_RADIUS
    end

    def height_at_apogee
      semi_major_axis * (1 + eccentricity) - Constant::EARTH_RADIUS
    end

    def eccentric_anomaly
      kepler = KeplersEquation.new(eccentricity:, mean_anomaly:)
      rad_to_deg(kepler.solve)
    end

    def true_anomaly
      e_rad = deg_to_rad(eccentric_anomaly)
      y = Math.sqrt(1 - eccentricity ** 2) * Math.sin(e_rad)
      x = Math.cos(e_rad) - eccentricity

      # atan2(y, x) で正確な位相（-pi から pi）を求める
      rad_to_deg(Math.atan2(y, x))
    end

    def distance
      semi_major_axis * (1 - eccentricity * Math.cos(deg_to_rad(eccentric_anomaly)))
    end

    def velocity
      Math.sqrt(Constant::GME * (2.0 / distance - 1.0 / semi_major_axis))
    end

    def path_angle
      return 0.0 if eccentricity < 1e-15

      factor = Math.sqrt(Constant::GME * semi_major_axis * (1 - eccentricity ** 2)) / (distance * velocity)
      rad_to_deg(Math.acos(factor))
    end

    def deg_to_rad(deg)
      rad = deg * Math::PI / 180.0
      normalize_rad(rad)
    end

    def normalize_rad(rad)
      rad = rad + 2.0 * Math::PI if rad < 0
      normalize_rad = rad > 2.0 * Math::PI ? rad - 2.0 * Math::PI : rad
      normalize_rad(normalize_rad) if normalize_rad != rad
      normalize_rad
    end

    def rad_to_deg(rad)
      deg = rad * 180.0 / Math::PI
      normalize_deg(deg)
    end

    def normalize_deg(deg)
      deg = deg + 360.0 if deg < 0
      normalized_deg = deg > 360.0 ? deg - 360.0 : deg
      normalize_deg(normalized_deg) if normalized_deg != deg
      normalized_deg
    end
  end
end
