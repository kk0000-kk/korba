# frozen_string_literal: true

RSpec.describe Korba::Tle do
  it "can create tle object from json" do
    tle_json = {
      "OBJECT_NAME": "ISS (ZARYA)",
      "OBJECT_ID": "1998-067A",
      "EPOCH": "2024-12-07T20:37:24.085056",
      "MEAN_MOTION": 15.50337242,
      "ECCENTRICITY": 0.0006817,
      "INCLINATION": 51.6381,
      "RA_OF_ASC_NODE": 174.9565,
      "ARG_OF_PERICENTER": 314.0303,
      "MEAN_ANOMALY": 175.4461,
      "EPHEMERIS_TYPE": 0,
      "CLASSIFICATION_TYPE": "U",
      "NORAD_CAT_ID": 25544,
      "ELEMENT_SET_NO": 999,
      "REV_AT_EPOCH": 48548,
      "BSTAR": 0.00032681,
      "MEAN_MOTION_DOT": 0.00018474,
      "MEAN_MOTION_DDOT": 0,
    }
    tle = Korba::Tle.new(tle_json, type: :json)
    expect(tle.object_name).to eq("ISS (ZARYA)")
    expect(tle.object_id).to eq("1998-067A")
    expect(tle.epoch).to eq("2024-12-07T20:37:24.085056")
    expect(tle.mean_motion).to eq(15.50337242)
    expect(tle.eccentricity).to eq(0.0006817)
    expect(tle.inclination).to eq(51.6381)
    expect(tle.ra_of_asc_node).to eq(174.9565)
    expect(tle.arg_of_pericenter).to eq(314.0303)
    expect(tle.mean_anomaly).to eq(175.4461)
    expect(tle.semi_major_axis).to eq(6793877.651258321)
    expect(tle.height_at_apogee).to eq(420372.03765318263)
    expect(tle.height_at_perigee).to eq(411109.26486345753)
  end

  it "can transform to kep" do
    tle_json = {
      "OBJECT_NAME": "ISS (ZARYA)",
      "OBJECT_ID": "1998-067A",
      "EPOCH": "2024-12-07T20:37:24.085056",
      "MEAN_MOTION": 15.50337242,
      "ECCENTRICITY": 0.0006817,
      "INCLINATION": 51.6381,
      "RA_OF_ASC_NODE": 174.9565,
      "ARG_OF_PERICENTER": 314.0303,
      "MEAN_ANOMALY": 175.4461,
      "EPHEMERIS_TYPE": 0,
      "CLASSIFICATION_TYPE": "U",
      "NORAD_CAT_ID": 25544,
      "ELEMENT_SET_NO": 999,
      "REV_AT_EPOCH": 48548,
      "BSTAR": 0.00032681,
      "MEAN_MOTION_DOT": 0.00018474,
      "MEAN_MOTION_DDOT": 0,
    }
    tle = Korba::Tle.new(tle_json, type: :json)
    kep = tle.to_kep
    expect(kep.object_name).to eq("ISS (ZARYA)")
    expect(kep.epoch).to eq("2024-12-07T20:37:24.085056")
    expect(kep.eccentricity).to eq(0.0006817)
    expect(kep.inclination).to eq(51.6381)
    expect(kep.ra_of_asc_node).to eq(174.9565)
    expect(kep.arg_of_pericenter).to eq(314.0303)
    expect(kep.mean_anomaly).to eq(175.4461)
    expect(kep.semi_major_axis).to eq(6793877.651258321)
    expect(kep.height_at_apogee).to eq(420372.03765318263)
    expect(kep.height_at_perigee).to eq(411109.26486345753)
  end

  it "can create tle object from string" do
    tle_text = <<~TLE
      ISS (ZARYA)
      1 25544U 98067A   24342.85930654  .00018474  00000+0  32681-3 0  9991
      2 25544  51.6381 174.9565 0006817 314.0303 175.4461 15.50337242485488
    TLE
    tle = Korba::Tle.new(tle_text, type: :string)
    expect(tle.object_name).to eq("ISS (ZARYA)")
    expect(tle.object_id).to be_nil
    expect(tle.epoch).to eq("2024-12-07T20:37:24.085055")
    expect(tle.mean_motion).to eq(15.50337242485488)
    expect(tle.eccentricity).to eq(0.0006817)
    expect(tle.inclination).to eq(51.6381)
    expect(tle.ra_of_asc_node).to eq(174.9565)
    expect(tle.arg_of_pericenter).to eq(314.0303)
    expect(tle.mean_anomaly).to eq(175.4461)
    expect(tle.semi_major_axis).to eq(6793877.649839985)
    expect(tle.height_at_apogee).to eq(420372.03623388056)
    expect(tle.height_at_perigee).to eq(411109.2634460889)
  end
end
