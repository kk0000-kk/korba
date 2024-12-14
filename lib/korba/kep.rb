# frozen_string_literal: true
require_relative "orbit_utils"

module Korba
  class Kep
    include Korba::OrbitUtils

    attr_reader :object_name, :epoch, :semi_major_axis, :eccentricity, :inclination, :ra_of_asc_node, :arg_of_pericenter, :mean_anomaly

    def initialize(object_name:, epoch:, semi_major_axis:, eccentricity:, inclination:, ra_of_asc_node:, arg_of_pericenter:, mean_anomaly:)
      @object_name = object_name
      @epoch = epoch
      @semi_major_axis = semi_major_axis
      @eccentricity = eccentricity
      @inclination = inclination
      @ra_of_asc_node = ra_of_asc_node
      @arg_of_pericenter = arg_of_pericenter
      @mean_anomaly = mean_anomaly
    end

    def to_car
    end

    def eccentric_anomaly
      f = Korba::KeplerEquationFunction.new(eccentricity:, mean_anomaly:)
      x = [deg_to_rad(mean_anomaly)]
      nlsolve(f, x)
      rad_to_deg(x[0])
    end
  end
end
