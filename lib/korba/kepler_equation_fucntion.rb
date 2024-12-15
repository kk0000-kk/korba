# frozen_string_literal: true
require_relative "newton_function"

module Korba
  class KeplerEquationFunction < NewtonFunction
    include OrbitUtils

    attr_reader :eccentricity, :mean_anomaly

    def initialize(eccentricity:, mean_anomaly:)
      super()
      @eccentricity = eccentricity
      @mean_anomaly = mean_anomaly
    end

    def values(x)
      [x[0] - eccentricity * Math.sin(x[0]) - deg_to_rad(mean_anomaly)]
    end
  end
end
