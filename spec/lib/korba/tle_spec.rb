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
    expect(tle.tle_json).to eq(tle_json)
    expect(tle.object_name).to eq("ISS (ZARYA)")
    expect(tle.object_id).to eq("1998-067A")
    expect(tle.satellite_number).to eq(25544)
    expect(tle.classification_type).to eq("U")
    expect(tle.epoch).to eq("2024-12-07T20:37:24.085056")
    expect(tle.mean_motion_dot).to eq 0.00018474
    expect(tle.mean_motion_ddot).to eq 0
    expect(tle.bstar).to eq(0.00032681)
    expect(tle.element_set_no).to eq(999)
    expect(tle.mean_motion).to eq(15.50337242)
    expect(tle.eccentricity).to eq(0.0006817)
    expect(tle.inclination).to eq(51.6381)
    expect(tle.ra_of_asc_node).to eq(174.9565)
    expect(tle.arg_of_pericenter).to eq(314.0303)
    expect(tle.mean_anomaly).to eq(175.4461)
    expect(tle.revolution_number).to eq(48548)
    expect(tle.semi_major_axis).to eq(6793877.651258321)
    expect(tle.height_at_apogee).to eq(420372.03765318263)
    expect(tle.height_at_perigee).to eq(411109.26486345753)
    expect(tle.epoch_datetime).to eq(Time.new("2024-12-07T20:37:24.085056 UTC"))
    expect(tle.julian_date[0]).to eq(2460651.5)
    expect(tle.julian_date[1]).to be_within(0.000001).of(0.8593055)
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
    expect(tle.tle_string).to eq(tle_text)
    expect(tle.object_name).to eq("ISS (ZARYA)")
    expect(tle.object_id).to be_nil
    expect(tle.satellite_number).to eq(25544)
    expect(tle.classification_type).to eq("U")
    expect(tle.epoch).to eq("2024-12-07T20:37:24.085055")
    expect(tle.mean_motion_dot).to eq 0.00018474
    expect(tle.mean_motion_ddot).to eq 0
    expect(tle.bstar).to be_within(0.00000001).of(0.00032681)
    expect(tle.element_set_no).to eq(999)
    expect(tle.mean_motion).to eq(15.50337242)
    expect(tle.eccentricity).to eq(0.0006817)
    expect(tle.inclination).to eq(51.6381)
    expect(tle.ra_of_asc_node).to eq(174.9565)
    expect(tle.arg_of_pericenter).to eq(314.0303)
    expect(tle.mean_anomaly).to eq(175.4461)
    expect(tle.revolution_number).to eq(48548)
    expect(tle.semi_major_axis).to eq(6793877.651258321)
    expect(tle.height_at_apogee).to eq(420372.03765318263)
    expect(tle.height_at_perigee).to eq(411109.26486345753)
    expect(tle.epoch_datetime).to eq(Time.new("2024-12-07T20:37:24.085055 UTC"))
    expect(tle.julian_date[0]).to eq(2460651.5)
    expect(tle.julian_date[1]).to be_within(0.000001).of(0.8593055)
  end

  it "can transform to car using sgp4" do
    tle_text = <<~TLE
      ISS (ZARYA)
      1 25544U 98067A   24342.85930654  .00018474  00000+0  32681-3 0  9991
      2 25544  51.6381 174.9565 0006817 314.0303 175.4461 15.50337242485488
    TLE
    tle = Korba::Tle.new(tle_text, type: :string)
    car = tle.propagate_to(0)
    expect(car.x).to be_within(0.001).of(4022283.8158334093)
    expect(car.y).to be_within(0.001).of(-3620488.4544254433)
    expect(car.z).to be_within(0.001).of(4106764.232424791)
    expect(car.vx).to be_within(0.001).of(6154.005139226364)
    expect(car.vy).to be_within(0.001).of(2490.4710952527043)
    expect(car.vz).to be_within(0.001).of(-3820.564288284213)
  end

  it "can propagate with sgp4" do
    tle_text = <<~TLE
      ISS (ZARYA)
      1 25544U 98067A 21226.49389238 .00001429 00000-0 34174-4 0 9998
      2 25544 51.6437 54.3833 0001250 307.1355 142.9078 15.48901431297630
    TLE
    tle = Korba::Tle.new(tle_text, type: :string)
    car = tle.propagate_to(728.7949728166666)
    expect(car.x).to be_within(0.001).of(1628523.7584667166)
    expect(car.y).to be_within(0.001).of(5888992.573497506)
    expect(car.z).to be_within(0.001).of(2972828.0145221233)
    expect(car.vx).to be_within(0.001).of(-5744.111950794902)
    expect(car.vy).to be_within(0.001).of(-935.3155449493028)
    expect(car.vz).to be_within(0.001).of(4984.380334289927)
  end
end
