# frozen_string_literal: true

module Korba
  class KeplersEquation
    include OrbitUtils

    attr_reader :eccentricity, :mean_anomaly

    def initialize(eccentricity:, mean_anomaly:)
      super()
      @eccentricity = eccentricity
      @mean_anomaly = mean_anomaly
    end

    MAX_ITERATIONS = 1000
    def solve(tolerance = 1e-10)
      m_rad = deg_to_rad(mean_anomaly)

      if eccentricity < 0.8
        en = m_rad
      else
        en = Math::PI
      end

      MAX_ITERATIONS.times do
        # f(E) = E - e*sin(E) - M
        # f'(E) = 1 - e*cos(E)

        sin_en = Math.sin(en.to_f)
        cos_en = Math.cos(en.to_f)

        f = en - eccentricity * sin_en - m_rad
        f_dot = 1 - eccentricity * cos_en

        # 更新
        delta = f / f_dot
        en = en - delta

        # 収束判定
        break if delta.abs < tolerance
      end

      en
    end
  end
end
