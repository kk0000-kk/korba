module Korba
  module Propagator
    class Rk4
      def initialize(initial_car, disable_j2: false)
        @initial_car = initial_car
        @disable_j2 = disable_j2
      end

      def propagate(seconds_after_epoch, dt = 1.0)
        steps = (seconds_after_epoch / dt).to_i
        t = 0.0
        y = Vector[@initial_car.x, @initial_car.y, @initial_car.z, @initial_car.vx, @initial_car.vy, @initial_car.vz]

        steps.times do
          y = step(t, y, dt)
          t += dt
        end

        Car.new(
          object_name: @initial_car.object_name,
          epoch: @initial_car.epoch + seconds_after_epoch,
          x: y[0],
          y: y[1],
          z: y[2],
          vx: y[3],
          vy: y[4],
          vz: y[5],
        )
      end

      private

      def step(t, y, dt)
        k1 = f(t, y)
        k2 = f(t + dt / 2.0, y + k1 * (dt / 2.0))
        k3 = f(t + dt / 2.0, y + k2 * (dt / 2.0))
        k4 = f(t + dt, y + k3 * dt)

        y + (k1 + 2 * k2 + 2 * k3 + k4) * (dt / 6.0)
      end

      def f(t, y)
        position_vector = Vector[y[0], y[1], y[2]]
        velocity_vector = Vector[y[3], y[4], y[5]]
        r = position_vector.magnitude
        base_acceleration_vector = -Constant::GME * position_vector / (r ** 3)
        acceleration_vector = @disable_j2 ? base_acceleration_vector : add_j2_effect(base_acceleration_vector, r, position_vector[2])

        Vector[velocity_vector[0], velocity_vector[1], velocity_vector[2], acceleration_vector[0], acceleration_vector[1], acceleration_vector[2]]
      end

      def add_j2_effect(base_acceleration_vector, r, z)
        j2_factor = (3.0 / 2.0) * Constant::J2 * (Constant::EARTH_RADIUS / r) ** 2
        factor = 5 * (z / r) ** 2
        [
          base_acceleration_vector[0] * (1 + j2_factor * (1 - factor)),
          base_acceleration_vector[1] * (1 + j2_factor * (1 - factor)),
          base_acceleration_vector[2] * (1 + j2_factor * (3 - factor)),
        ]
      end
    end
  end
end
