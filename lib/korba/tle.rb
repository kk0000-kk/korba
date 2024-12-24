# frozen_string_literal: true
require_relative "orbit_utils"

module Korba
  class Tle
    include OrbitUtils

    attr_reader :tle_json, :tle_string, :object_id, :object_name, :epoch_datetime, :julian_date,
                :satellite_number, :classification_type, :epoch, :bstar, :element_set_no,
                :inclination, :ra_of_asc_node, :eccentricity, :arg_of_pericenter, :mean_anomaly, :mean_motion, :revolution_number

    def initialize(tle = nil, type: :string)
      return if tle.nil?

      case type
      when :string
        initialize_from_string(tle)
      when :json
        initialize_from_json(tle)
      end
      set_epoch_datetime_and_julian_date
    end

    def to_kep
      Kep.new(object_name:,
              epoch:,
              semi_major_axis:,
              eccentricity:,
              inclination:,
              ra_of_asc_node:,
              arg_of_pericenter:,
              mean_anomaly:)
    end

    def to_car
      kep = to_kep
      kep.to_car
    end

    private

    def initialize_from_string(tle_string)
      @tle_string = tle_string
      lines = tle_string.split(/\R/)
      @object_name = lines.shift if lines.size > 2
      parse_line1(lines[0].split(" "))
      parse_line2(lines[1].split(" "))
    end

    def parse_line1(line1_strings)
      # TODO: object_id
      @satellite_number = line1_strings[1][0..4].to_i
      @classification_type = line1_strings[1][-1]
      # For now, only supports years after 2000
      epoch_year = line1_strings[3][0..1].to_i + 2000
      epoch_day_of_year = line1_strings[3][2..].to_f
      # Subtract 1 from epoch_day_of_year because January 1st is considered day 1
      epoch_time = Time.new(epoch_year, 1, 1, 0, 0, 0, "+00:00") + (epoch_day_of_year - 1) * 24 * 60 * 60
      @epoch = epoch_time.strftime("%Y-%m-%dT%H:%M:%S.%6N")

      bstar_sign = line1_strings[6][0] == "-" ? -1 : 1
      bstar_value_start = line1_strings[6].size == 8 ? 1 : 0
      bstar_exponent = line1_strings[6][bstar_value_start + 5..bstar_value_start + 6].to_i
      @bstar = bstar_sign * "0.#{line1_strings[6][bstar_value_start..bstar_value_start + 4]}".to_f * 10 ** bstar_exponent

      @element_set_no = line1_strings[8][0..2].to_i
    end

    def parse_line2(line2_strings)
      @inclination = line2_strings[2].to_f
      @ra_of_asc_node = line2_strings[3].to_f
      @eccentricity = "0.#{line2_strings[4]}".to_f
      @arg_of_pericenter = line2_strings[5].to_f
      @mean_anomaly = line2_strings[6].to_f
      @mean_motion = line2_strings[7][0..10].to_f
      @revolution_number = line2_strings[7][11..15].to_i
    end

    def initialize_from_json(tle_json)
      @tle_json = tle_json
      @object_name = tle_json[:OBJECT_NAME]
      @object_id = tle_json[:OBJECT_ID]
      @satellite_number = tle_json[:NORAD_CAT_ID]
      @classification_type = tle_json[:CLASSIFICATION_TYPE]
      @epoch = tle_json[:EPOCH]
      @bstar = tle_json[:BSTAR]
      @element_set_no = tle_json[:ELEMENT_SET_NO]
      @mean_motion = tle_json[:MEAN_MOTION]
      @eccentricity = tle_json[:ECCENTRICITY]
      @inclination = tle_json[:INCLINATION]
      @ra_of_asc_node = tle_json[:RA_OF_ASC_NODE]
      @arg_of_pericenter = tle_json[:ARG_OF_PERICENTER]
      @mean_anomaly = tle_json[:MEAN_ANOMALY]
      @revolution_number = tle_json[:REV_AT_EPOCH]
    end

    def set_epoch_datetime_and_julian_date
      @epoch_datetime = Time.new(@epoch + " UTC")
      @julian_date = SGP4.jday(
        epoch_datetime.year, epoch_datetime.mon, epoch_datetime.day, epoch_datetime.hour, epoch_datetime.min, epoch_datetime.sec
      )
    end
  end
end
