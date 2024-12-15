# frozen_string_literal: true

module Korba
  module OrbitUtils
    def semi_major_axis
      # a = (μ / n^2)^(1/3) m
      (Constant::GME / (mean_motion * 2 * Math::PI / 86400.0) ** 2.0) ** (1.0 / 3.0)
    end

    def height_at_perigee
      semi_major_axis * (1 - eccentricity) - Constant::EARTH_RADIUS
    end

    def height_at_apogee
      semi_major_axis * (1 + eccentricity) - Constant::EARTH_RADIUS
    end

    def eccentric_anomaly
      f = KeplerEquationFunction.new(eccentricity:, mean_anomaly:)
      x = [deg_to_rad(mean_anomaly)]
      nlsolve(f, x)
      rad_to_deg(x[0])
    end

    def true_anomaly
      factor = (Math.cos(deg_to_rad(eccentric_anomaly)) - eccentricity) / (1 - eccentricity * Math.cos(deg_to_rad(eccentric_anomaly)))
      rad_to_deg(Math.acos(factor))
    end

    def distance
      semi_major_axis * (1 - eccentricity * Math.cos(deg_to_rad(eccentric_anomaly)))
    end

    def velocity
      Math.sqrt(Constant::GME * (2 / distance - 1 / semi_major_axis))
    end

    def path_angle
      factor = Math.sqrt(Constant::GME * semi_major_axis * (1 - eccentricity ** 2)) / (distance * velocity)
      rad_to_deg(Math.acos(factor))
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
