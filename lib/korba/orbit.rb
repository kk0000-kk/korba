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

      def from_keplerian(keplerian)
        new(keplerian:, epoch: keplerian.epoch, name: keplerian.object_name)
      end

      def from_cartesian(cartesian)
        new(cartesian:, epoch: cartesian.epoch, name: cartesian.object_name)
      end
    end

    def initialize(keplerian: nil, cartesian: nil, tle: nil, epoch: nil, name: nil)
      @keplerian = keplerian
      @cartesian = cartesian
      @tle = tle
      @epoch = epoch
      @name = name
    end

    def cartesian
      @cartesian ||= tle_to_cartesian(tle) || keplerian_to_cartesian(keplerian)
    end

    def keplerian
      @keplerian ||= tle_to_keplerian(tle) || cartesian_to_keplerian(cartesian)
    end

    def propagate(type:, seconds_after_epoch:, disable_j2: false)
      case type.to_sym
      in :sgp4
        propagated_cartesian = tle.propagate_to(seconds_after_epoch / 60.0)
        return Orbit.from_cartesian(propagated_cartesian)
      in :rk4
        propagator = Propagator::Rk4.new(cartesian, disable_j2:)
        propagated_cartesian = propagator.propagate(seconds_after_epoch)
        return Orbit.from_cartesian(propagated_cartesian)
      in :kepler
        propagator = Propagator::Kepler.new(keplerian, disable_j2:)
        propagated_keplerian = propagator.propagate(seconds_after_epoch)
        return Orbit.from_keplerian(propagated_keplerian)
      end
    end
  end
end
