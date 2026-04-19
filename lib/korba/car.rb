# frozen_string_literal: true

module Korba
  class Car
    include OrbitUtils

    attr_reader :object_name, :epoch, :x, :y, :z, :vx, :vy, :vz

    def initialize(object_name:, epoch:, x:, y:, z:, vx:, vy:, vz:)
      @object_name = object_name
      @epoch = epoch
      @x = x
      @y = y
      @z = z
      @vx = vx
      @vy = vy
      @vz = vz
    end

    def to_kep
      inclination = rad_to_deg(Math.atan2(Math.sqrt(specific_angular_momentum_vector[0] ** 2 + specific_angular_momentum_vector[1] ** 2), specific_angular_momentum_vector[2]))
      ra_of_asc_node = rad_to_deg(Math.atan2(specific_angular_momentum_vector[0], -specific_angular_momentum_vector[1]))

      Kep.new(object_name:,
              epoch:,
              semi_major_axis:,
              eccentricity:,
              inclination:,
              ra_of_asc_node:,
              arg_of_pericenter: normalize_deg(arg_of_latitude - true_anomaly),
              mean_anomaly: rad_to_deg(deg_to_rad(eccentric_anomaly) - eccentricity * Math.sin(deg_to_rad(eccentric_anomaly))))
    end

    private

    def position_vector
      @position_vector ||= Vector[x, y, z]
    end

    def velocity_vector
      @velocity_vector ||= Vector[vx, vy, vz]
    end

    def distance
      @distance ||= position_vector.norm
    end

    def velocity
      @velocity ||= velocity_vector.norm
    end

    def semi_major_axis
      @semi_major_axis ||= Constant::GME * distance / (2 * Constant::GME - distance * velocity ** 2)
    end

    def eccentricity
      @eccentricity ||= Math.sqrt(((semi_major_axis - distance) / semi_major_axis) ** 2 + (position_vector.dot(velocity_vector) ** 2) / (Constant::GME * semi_major_axis))
    end

    def eccentric_anomaly
      @eccentric_anomaly ||= rad_to_deg(Math.atan2(Math.sqrt(semi_major_axis / Constant::GME) * position_vector.dot(velocity_vector), semi_major_axis - distance))
    end

    def true_anomaly
      factor = (Math.cos(deg_to_rad(eccentric_anomaly)) - eccentricity) / (1 - eccentricity * Math.cos(deg_to_rad(eccentric_anomaly)))
      rad_to_deg(Math.atan2(Math.sqrt(1 - factor ** 2), factor))
    end

    def angular_momentum_vector
      @angular_momentum_vector ||= position_vector.cross(velocity_vector)
    end

    def raan_vector
      @raan_vector ||= Vector[0, 0, 1].cross(angular_momentum_vector)
    end

    def eccentricity_vector
      @eccentricity_vector ||= ((velocity ** 2 - Constant::GME / distance) * position_vector - (position_vector * velocity_vector) * velocity_vector) / Constant::GME
    end

    def specific_angular_momentum_vector
      @specific_angular_momentum_vector ||= position_vector.cross(velocity_vector)
    end

    def raan_vector
      @raan_vector ||= Vector[0, 0, 1].cross(specific_angular_momentum_vector)
    end

    def arg_of_latitude
      y = position_vector.dot(raan_vector)
      x = position_vector.norm * raan_vector.norm
      arg_of_latitude = (Math.atan2(
        Math.sqrt(1 - (y / x) ** 2),
        y / x
      ))
      arg_of_latitude = 2 * Math::PI - arg_of_latitude if z < 0
      rad_to_deg(arg_of_latitude)
    end
  end
end
