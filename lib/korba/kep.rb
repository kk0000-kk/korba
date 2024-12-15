# frozen_string_literal: true
require "matrix"

module Korba
  class Kep
    include OrbitUtils

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
      vector_n = Vector[
        Math.sin(deg_to_rad(inclination)) * Math.sin(deg_to_rad(ra_of_asc_node)),
        -Math.sin(deg_to_rad(inclination)) * Math.cos(deg_to_rad(ra_of_asc_node)),
        Math.cos(deg_to_rad(inclination))
      ]
      vector_omega = Vector[Math.cos(deg_to_rad(ra_of_asc_node)), Math.sin(deg_to_rad(ra_of_asc_node)), 0]
      vector_m = vector_n.cross(vector_omega)

      r_angle_factor = deg_to_rad(arg_of_pericenter + true_anomaly)
      vector_r = distance * (Math.cos(r_angle_factor) * vector_omega + Math.sin(r_angle_factor) * vector_m)
      v_angle_factor = deg_to_rad(arg_of_pericenter + true_anomaly - path_angle)
      vector_v = velocity * (-Math.sin(v_angle_factor) * vector_omega + (Math.cos(v_angle_factor)) * vector_m)

      Car.new(object_name:, epoch:, x: vector_r[0], y: vector_r[1], z: vector_r[2], vx: vector_v[0], vy: vector_v[1], vz: vector_v[2])
    end
  end
end
