# frozen_string_literal: true

RSpec.describe Korba::Tle do
  it "can create tle object" do
    tle_json = {
      "OBJECT_NAME": "ISS (ZARYA)",
      "OBJECT_ID": "1998-067A",
      "EPOCH": "2024-12-06T23:01:29.104896",
      "MEAN_MOTION": 15.50304543,
      "ECCENTRICITY": 0.0006947,
      "INCLINATION": 51.6383,
      "RA_OF_ASC_NODE": 179.4169,
      "ARG_OF_PERICENTER": 310.0949,
      "MEAN_ANOMALY": 193.3515,
      "EPHEMERIS_TYPE": 0,
      "CLASSIFICATION_TYPE": "U",
      "NORAD_CAT_ID": 25544,
      "ELEMENT_SET_NO": 999,
      "REV_AT_EPOCH": 48534,
      "BSTAR": 0.00033207,
      "MEAN_MOTION_DOT": 0.00018758,
      "MEAN_MOTION_DDOT": 0,
    }
    tle = Korba::Tle.new(tle_json)
    expect(tle.object_name).to eq("ISS (ZARYA)")
    expect(tle.object_id).to eq("1998-067A")
    expect(tle.epoch).to eq("2024-12-06T23:01:29.104896")
    expect(tle.mean_motion).to eq(15.50304543)
    expect(tle.eccentricity).to eq(0.0006947)
    expect(tle.inclination).to eq(51.6383)
    expect(tle.ra_of_asc_node).to eq(179.4169)
    expect(tle.arg_of_pericenter).to eq(310.0949)
    expect(tle.mean_anomaly).to eq(193.3515)
    expect(tle.semi_major_axis).to eq(6793973.181832356)
  end

  it "can transform to kep" do
    tle_json = {
      "OBJECT_NAME": "ISS (ZARYA)",
      "OBJECT_ID": "1998-067A",
      "EPOCH": "2024-12-06T23:01:29.104896",
      "MEAN_MOTION": 15.50304543,
      "ECCENTRICITY": 0.0006947,
      "INCLINATION": 51.6383,
      "RA_OF_ASC_NODE": 179.4169,
      "ARG_OF_PERICENTER": 310.0949,
      "MEAN_ANOMALY": 193.3515,
      "EPHEMERIS_TYPE": 0,
      "CLASSIFICATION_TYPE": "U",
      "NORAD_CAT_ID": 25544,
      "ELEMENT_SET_NO": 999,
      "REV_AT_EPOCH": 48534,
      "BSTAR": 0.00033207,
      "MEAN_MOTION_DOT": 0.00018758,
      "MEAN_MOTION_DDOT": 0,
    }
    tle = Korba::Tle.new(tle_json)
    kep = tle.to_kep
    expect(kep.object_name).to eq("ISS (ZARYA)")
    expect(kep.epoch).to eq("2024-12-06T23:01:29.104896")
    expect(kep.semi_major_axis).to eq(6793973.181832356)
    expect(kep.eccentricity).to eq(0.0006947)
    expect(kep.inclination).to eq(51.6383)
    expect(kep.ra_of_asc_node).to eq(179.4169)
    expect(kep.arg_of_pericenter).to eq(310.0949)
    expect(kep.mean_anomaly).to eq(193.3515)
  end
end
