# frozen_string_literal: true
module Korba
  class Tle
    attr_reader :tle_json, :object_name, :object_id, :epoch, :mean_motion, :eccentricity, :inclination, :ra_of_asc_node, :arg_of_pericenter, :mean_anomaly

    def initialize(tle_json)
      @tle_json = tle_json
      @object_name = tle_json[:OBJECT_NAME]
      @object_id = tle_json[:OBJECT_ID]
      @epoch = tle_json[:EPOCH]
      @mean_motion = tle_json[:MEAN_MOTION]
      @eccentricity = tle_json[:ECCENTRICITY]
      @inclination = tle_json[:INCLINATION]
      @ra_of_asc_node = tle_json[:RA_OF_ASC_NODE]
      @arg_of_pericenter = tle_json[:ARG_OF_PERICENTER]
      @mean_anomaly = tle_json[:MEAN_ANOMALY]
    end

    def semi_major_axis
      # a = (μ / n^2)^(1/3) m
      (Korba::Constant::GME / (mean_motion * 2 * Math::PI / 86400.0) ** 2.0) ** (1.0 / 3.0)
    end

    def to_kep
      Korba::Kep.new(object_name:,
                     epoch:,
                     semi_major_axis:,
                     eccentricity:,
                     inclination:,
                     ra_of_asc_node:,
                     arg_of_pericenter:,
                     mean_anomaly:)
    end
  end
end
