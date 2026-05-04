module Korba
  module Propagator
    class Kepler
      include OrbitUtils

      def initialize(initial_kep, disable_j2: false)
        @initial_kep = initial_kep
        @disable_j2 = disable_j2
      end

      def propagate(seconds_after_epoch)
        mean_motion = Math.sqrt(Constant::GME / @initial_kep.semi_major_axis ** 3)
        mean_anomaly = rad_to_deg(deg_to_rad(@initial_kep.mean_anomaly) + mean_motion * seconds_after_epoch)

        Kep.new(
          object_name: @initial_kep.object_name,
          epoch: @initial_kep.epoch + seconds_after_epoch,
          semi_major_axis: @initial_kep.semi_major_axis,
          eccentricity: @initial_kep.eccentricity,
          inclination: @initial_kep.inclination,
          ra_of_asc_node: ra_of_asc_node(seconds_after_epoch),
          arg_of_pericenter: arg_of_pericenter(seconds_after_epoch),
          mean_anomaly: mean_anomaly,
        )
      end

      private

      def ra_of_asc_node(seconds_after_epoch)
        return @initial_kep.ra_of_asc_node if @disable_j2

        normalize_deg(@initial_kep.ra_of_asc_node + delta_ra_of_asc_node * seconds_after_epoch)
      end

      def delta_ra_of_asc_node
        -rad_to_deg(3 * Math::PI * Constant::J2 *
                    (Constant::EARTH_RADIUS / @initial_kep.semi_major_axis * (1 - @initial_kep.eccentricity ** 2)) ** 2 *
                    Math.cos(deg_to_rad(@initial_kep.inclination))) / @initial_kep.period
      end

      def arg_of_pericenter(seconds_after_epoch)
        return @initial_kep.arg_of_pericenter if @disable_j2

        normalize_deg(@initial_kep.arg_of_pericenter + delta_arg_of_pericenter * seconds_after_epoch)
      end

      def delta_arg_of_pericenter
        rad_to_deg(3 * Math::PI / 2.0 * Constant::J2 *
                   (Constant::EARTH_RADIUS / @initial_kep.semi_major_axis * (1 - @initial_kep.eccentricity ** 2)) ** 2 *
                   (5 * (Math.cos(deg_to_rad(@initial_kep.inclination)) ** 2) - 1)) / @initial_kep.period
      end
    end
  end
end
