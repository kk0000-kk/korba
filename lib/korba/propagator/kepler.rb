module Korba
  module Propagator
    class Kepler
      include OrbitUtils

      def initialize(initial_kep)
        @initial_kep = initial_kep
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
          ra_of_asc_node: @initial_kep.ra_of_asc_node,
          arg_of_pericenter: @initial_kep.arg_of_pericenter,
          mean_anomaly: mean_anomaly,
        )
      end
    end
  end
end
