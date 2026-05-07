# frozen_string_literal: true

RSpec.describe Korba::Orbit do
  describe 'tle' do
    it "tleから軌道を生成できること" do
      tle_text = <<~TLE
        ISS (ZARYA)
        1 25544U 98067A   24342.85930654  .00018474  00000+0  32681-3 0  9991
        2 25544  51.6381 174.9565 0006817 314.0303 175.4461 15.50337242485488
      TLE
      orbit = Korba::Orbit.from_tle(tle_text, type: :string)

      expect(orbit.tle.object_name).to eq("ISS (ZARYA)")
      expect(orbit.tle.sattelite_id).to be_nil
      expect(orbit.tle.satellite_number).to eq(25544)
      expect(orbit.tle.classification_type).to eq("U")
      expect(orbit.tle.epoch).to eq("2024-12-07T20:37:24.085055")
      expect(orbit.tle.mean_motion_dot).to eq 0.00018474
      expect(orbit.tle.mean_motion_ddot).to eq 0
      expect(orbit.tle.bstar).to be_within(0.00000001).of(0.00032681)
      expect(orbit.tle.element_set_no).to eq(999)
      expect(orbit.tle.mean_motion).to eq(15.50337242)
      expect(orbit.tle.eccentricity).to eq(0.0006817)
      expect(orbit.tle.inclination).to eq(51.6381)
      expect(orbit.tle.ra_of_asc_node).to eq(174.9565)
      expect(orbit.tle.arg_of_pericenter).to eq(314.0303)
      expect(orbit.tle.mean_anomaly).to eq(175.4461)
      expect(orbit.tle.revolution_number).to eq(48548)
      expect(orbit.tle.semi_major_axis).to eq(6793877.651258321)
      expect(orbit.tle.height_at_apogee).to eq(420372.03765318263)
      expect(orbit.tle.height_at_perigee).to eq(411109.26486345753)
      expect(orbit.tle.epoch_datetime).to eq(Time.new("2024-12-07T20:37:24.085055 UTC"))
      expect(orbit.tle.julian_date[0]).to eq(2460651.5)
      expect(orbit.tle.julian_date[1]).to be_within(0.000001).of(0.8593055)
      expect(orbit.epoch).to eq(Time.new("2024-12-07T20:37:24.085055 UTC"))
      expect(orbit.name).to eq("ISS (ZARYA)")
      expect(orbit.frame).to eq(Korba::Frame::ECI_TEME)

      car = orbit.cartesian
      expect(car.epoch).to eq(Time.new("2024-12-07T20:37:24.085055 UTC"))
      expect(car.x).to be_within(0.001).of(4022283.8158334093)
      expect(car.y).to be_within(0.001).of(-3620488.4544254433)
      expect(car.z).to be_within(0.001).of(4106764.232424791)
      expect(car.vx).to be_within(0.001).of(6154.005139226364)
      expect(car.vy).to be_within(0.001).of(2490.4710952527043)
      expect(car.vz).to be_within(0.001).of(-3820.564288284213)

      kep = orbit.keplerian
      expect(kep.object_name).to eq("ISS (ZARYA)")
      expect(kep.epoch).to eq(Time.new("2024-12-07T20:37:24.085055 UTC"))
      expect(kep.eccentricity).to eq(0.0006817)
      expect(kep.inclination).to eq(51.6381)
      expect(kep.ra_of_asc_node).to eq(174.9565)
      expect(kep.arg_of_pericenter).to eq(314.0303)
      expect(kep.mean_anomaly).to eq(175.4461)
      expect(kep.semi_major_axis).to eq(6793877.651258321)
      expect(kep.height_at_apogee).to eq(420372.03765318263)
      expect(kep.height_at_perigee).to eq(411109.26486345753)
    end

    it 'SGP4で伝搬できること' do
      tle_text = <<~TLE
        ISS (ZARYA)
        1 25544U 98067A 21226.49389238 .00001429 00000-0 34174-4 0 9998
        2 25544 51.6437 54.3833 0001250 307.1355 142.9078 15.48901431297630
      TLE
      orbit = Korba::Orbit.from_tle(tle_text, type: :string)
      expect(orbit.tle.epoch_datetime).to eq(Time.new("2021-08-14T11:51:12.301631 UTC"))

      propagated_orbit = orbit.propagate(type: :sgp4, seconds_after_epoch: 728.7949728166666 * 60.0)
      car = propagated_orbit.cartesian
      expect(car.epoch).to be_within(0.000001).of(Time.new("2021-08-15T00:00:00.000000 UTC"))
      expect(car.x).to be_within(0.001).of(1628523.7584667166)
      expect(car.y).to be_within(0.001).of(5888992.573497506)
      expect(car.z).to be_within(0.001).of(2972828.0145221233)
      expect(car.vx).to be_within(0.001).of(-5744.111950794902)
      expect(car.vy).to be_within(0.001).of(-935.3155449493028)
      expect(car.vz).to be_within(0.001).of(4984.380334289927)
    end

    it 'RK4で伝搬できること' do
      tle_text = <<~TLE
        ISS (ZARYA)
        1 25544U 98067A 21226.49389238 .00001429 00000-0 34174-4 0 9998
        2 25544 51.6437 54.3833 0001250 307.1355 142.9078 15.48901431297630
      TLE
      orbit = Korba::Orbit.from_tle(tle_text, type: :string)
      expect(orbit.tle.epoch_datetime).to eq(Time.new("2021-08-14T11:51:12.301631 UTC"))

      propagated_orbit = orbit.propagate(type: :rk4, seconds_after_epoch: 728.7949728166666 * 60.0)
      car = propagated_orbit.cartesian
      expect(car.epoch).to be_within(0.000001).of(Time.new("2021-08-15T00:00:00.000000 UTC"))
      expect(car.x).to be_within(0.001).of(1632653.9188536466)
      expect(car.y).to be_within(0.001).of(5889777.609733359)
      expect(car.z).to be_within(0.001).of(2969392.9959819214)
      expect(car.vx).to be_within(0.001).of(-5742.554621610066)
      expect(car.vy).to be_within(0.001).of(-930.0862111128096)
      expect(car.vz).to be_within(0.001).of(4986.875385566524)
    end

    it 'Keplerで伝搬できること' do
      tle_text = <<~TLE
        ISS (ZARYA)
        1 25544U 98067A 21226.49389238 .00001429 00000-0 34174-4 0 9998
        2 25544 51.6437 54.3833 0001250 307.1355 142.9078 15.48901431297630
      TLE
      orbit = Korba::Orbit.from_tle(tle_text, type: :string)
      expect(orbit.tle.epoch_datetime).to eq(Time.new("2021-08-14T11:51:12.301631 UTC"))

      propagated_orbit = orbit.propagate(type: :kepler, seconds_after_epoch: 728.7949728166666 * 60.0)
      car = propagated_orbit.cartesian
      expect(car.epoch).to be_within(0.000001).of(Time.new("2021-08-15T00:00:00.000000 UTC"))
      expect(car.x).to be_within(0.001).of(1622933.1965950136)
      expect(car.y).to be_within(0.001).of(5889951.975955185)
      expect(car.z).to be_within(0.001).of(2981170.355794883)
      expect(car.vx).to be_within(0.001).of(-5742.384964525863)
      expect(car.vy).to be_within(0.001).of(-936.3853027106695)
      expect(car.vz).to be_within(0.001).of(4978.331300943234)
    end
  end

  describe 'keplerian' do
    it "keplerianから軌道を生成できること" do
      kep = Korba::Kep.new(
        object_name: "ISS (ZARYA)",
        eccentricity: 0.0006817,
        inclination: 51.6381,
        ra_of_asc_node: 174.9565,
        arg_of_pericenter: 314.0303,
        mean_anomaly: 175.4461,
        epoch: Time.new("2024-12-07T20:37:24.085055 UTC"),
        semi_major_axis: 6793877.651258321,
      )
      orbit = Korba::Orbit.from_keplerian(kep)
      expect(orbit.frame).to eq(Korba::Frame::ECI_J2000)

      kep = orbit.keplerian
      expect(kep.object_name).to eq("ISS (ZARYA)")
      expect(kep.epoch).to eq(Time.new("2024-12-07T20:37:24.085055 UTC"))
      expect(kep.eccentricity).to eq(0.0006817)
      expect(kep.inclination).to eq(51.6381)
      expect(kep.ra_of_asc_node).to eq(174.9565)
      expect(kep.arg_of_pericenter).to eq(314.0303)
      expect(kep.mean_anomaly).to eq(175.4461)
      expect(kep.semi_major_axis).to eq(6793877.651258321)
      expect(kep.height_at_apogee).to eq(420372.03765318263)
      expect(kep.height_at_perigee).to eq(411109.26486345753)

      car = orbit.cartesian
      expect(car.epoch).to eq(Time.new("2024-12-07T20:37:24.085055 UTC"))
      expect(car.x).to be_within(0.001).of(4019753.8630564497)
      expect(car.y).to be_within(0.001).of(-3623966.5194109976)
      expect(car.z).to be_within(0.001).of(4114361.694309395)
      expect(car.vx).to be_within(0.001).of(6150.77241020284)
      expect(car.vy).to be_within(0.001).of(2489.329877850559)
      expect(car.vz).to be_within(0.001).of(-3816.0301662670786)
    end
  end

  describe 'cartesian' do
    it "cartesianから軌道を生成できること" do
      car = Korba::Car.new(
        object_name: "ISS (ZARYA)",
        epoch: Time.new("2024-12-07T20:37:24.085055 UTC"),
        x: 4019753.863,
        y: -3623966.519,
        z: 4114361.694,
        vx: 6150.772,
        vy: 2489.330,
        vz: -3816.030,
      )
      orbit = Korba::Orbit.from_cartesian(car)
      expect(orbit.frame).to eq(Korba::Frame::ECI_J2000)

      car = orbit.cartesian
      expect(car.object_name).to eq("ISS (ZARYA)")
      expect(car.epoch).to eq(Time.new("2024-12-07T20:37:24.085055 UTC"))
      expect(car.x).to be_within(0.001).of(4019753.863)
      expect(car.y).to be_within(0.001).of(-3623966.519)
      expect(car.z).to be_within(0.001).of(4114361.694)
      expect(car.vx).to be_within(0.001).of(6150.772)
      expect(car.vy).to be_within(0.001).of(2489.330)
      expect(car.vz).to be_within(0.001).of(-3816.030)

      kep = orbit.keplerian
      expect(kep.object_name).to eq("ISS (ZARYA)")
      expect(kep.epoch).to eq(Time.new("2024-12-07T20:37:24.085055 UTC"))
      expect(kep.eccentricity).to be_within(0.0000001).of(0.0006817)
      expect(kep.inclination).to be_within(0.0001).of(51.6381)
      expect(kep.ra_of_asc_node).to be_within(0.0001).of(174.9565)
      expect(kep.arg_of_pericenter).to be_within(0.01).of(314.0303)
      expect(kep.mean_anomaly).to be_within(0.01).of(175.4461)
      expect(kep.semi_major_axis).to be_within(1).of(6793877.651258321)
      expect(kep.height_at_apogee).to be_within(0.02).of(420372.03765318263)
      expect(kep.height_at_perigee).to be_within(2).of(411109.26486345753)
    end
  end
end
