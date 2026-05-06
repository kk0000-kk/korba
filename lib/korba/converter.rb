# frozen_string_literal: true

module Korba
  module Converter
    def tle_to_cartesian(tle)
      return nil if tle.nil?

      tle.to_car
    end

    def tle_to_keplerian(tle)
      return nil if tle.nil?

      tle.to_kep
    end

    def keplerian_to_cartesian(keplerian)
      return nil if keplerian.nil?

      keplerian.to_car
    end

    def cartesian_to_keplerian(cartesian)
      return nil if cartesian.nil?

      cartesian.to_kep
    end
  end
end
