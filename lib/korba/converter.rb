# frozen_string_literal: true

module Korba
  module Converter
    def tle_to_car(tle)
      return nil if tle.nil?

      tle.to_car
    end

    def tle_to_kep(tle)
      return nil if tle.nil?

      tle.to_kep
    end

    def kep_to_car(kep)
      return nil if kep.nil?

      kep.to_car
    end
  end
end
