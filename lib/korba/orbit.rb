# frozen_string_literal: true

module Korba
  class Orbit
    include Converter
    attr_reader :epoch, :name, :tle

    class << self
      def from_tle(tle = nil, type: :string)
        tle = Tle.new(tle, type:)
        new(tle:, epoch: tle.epoch_datetime, name: tle.object_name)
      end

      def from_kep(kep)
        new(kep:, epoch: kep.epoch, name: kep.object_name)
      end

      def from_car(car)
        new(car:, epoch: car.epoch, name: car.object_name)
      end
    end

    def initialize(kep: nil, car: nil, tle: nil, epoch: nil, name: nil)
      @kep = kep
      @car = car
      @tle = tle
      @epoch = epoch
      @name = name
    end

    def car
      @car ||= tle_to_car(tle) || kep_to_car(kep)
    end

    def kep
      @kep ||= tle_to_kep(tle) || car_to_kep(car)
    end

    def propagate(type:, seconds_after_epoch:, disable_j2: false)
      case type.to_sym
      in :sgp4
        propagated_car = tle.propagate_to(seconds_after_epoch / 60.0)
        return Orbit.from_car(propagated_car)
      in :rk4
        propagator = Propagator::Rk4.new(car, disable_j2:)
        propagated_car = propagator.propagate(seconds_after_epoch)
        return Orbit.from_car(propagated_car)
      in :kepler
        propagator = Propagator::Kepler.new(kep, disable_j2:)
        propagated_kep = propagator.propagate(seconds_after_epoch)
        return Orbit.from_kep(propagated_kep)
      end
    end
  end
end
