# frozen_string_literal: true
module Korba
  class Tle
    attr_reader :tle_json, :object_name, :object_id, :epoch, :mean_motion, :eccentricity, :inclination, :ra_of_asc_node, :arg_of_pericenter, :mean_anomaly

    def initialize(tle, type: :string)
      case type
      when :string
        initialize_from_string(tle)
      when :json
        initialize_from_json(tle)
      end
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

    private

    def initialize_from_string(tle_string)
      lines = tle_string.split(/\R/)
      @object_name = lines.shift if lines.size > 2
      parse_line1(lines[0].split(" "))
      parse_line2(lines[1].split(" "))
    end

    def parse_line1(line1_strings)
      # TODO: object_id
      # For now, only supports years after 2000
      epoch_year = line1_strings[3][0..1].to_i + 2000
      epoch_day_of_year = line1_strings[3][2..].to_f
      # Subtract 1 from epoch_day_of_year because January 1st is considered day 1
      epoch_time = Time.new(epoch_year, 1, 1, 0, 0, 0, "+00:00") + (epoch_day_of_year - 1) * 24 * 60 * 60
      @epoch = epoch_time.strftime("%Y-%m-%dT%H:%M:%S.%6N")
    end

    def parse_line2(line2_strings)
      @inclination = line2_strings[2].to_f
      @ra_of_asc_node = line2_strings[3].to_f
      @eccentricity = "0.#{line2_strings[4]}".to_f
      @arg_of_pericenter = line2_strings[5].to_f
      @mean_anomaly = line2_strings[6].to_f
      @mean_motion = line2_strings[7].to_f
    end

    def initialize_from_json(tle_json)
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
  end
end
