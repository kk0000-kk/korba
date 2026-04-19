# frozen_string_literal: true

RSpec.describe Korba::Propagator::Rk4 do
  it "j2考慮なしの場合、高度400kmの円軌道の衛星を約1時間半に伝播させるとだいたい1周すること" do
    initial_orbit = Korba::Kep.new(
      object_name: "TestSat",
      epoch: Time.new(2026, 1, 1, 0, 0, 0),
      semi_major_axis: Korba::Constant::EARTH_RADIUS + 400_000,
      eccentricity: 0.0,
      inclination: 0.0,
      ra_of_asc_node: 0.0,
      arg_of_pericenter: 0.0,
      mean_anomaly: 0.0,
    )
    rk4 = Korba::Propagator::Rk4.new(initial_orbit.to_car, disable_j2: true)
    propagated_car = rk4.propagate(5553)

    expect(propagated_car.x).to be_within(100).of(initial_orbit.to_car.x)
    # TODO: y軸の誤差が大きい
    expect(propagated_car.y).to be_within(5000).of(initial_orbit.to_car.y)
    expect(propagated_car.z).to be_within(100).of(initial_orbit.to_car.z)
    expect(propagated_car.vx).to be_within(100).of(initial_orbit.to_car.vx)
    expect(propagated_car.vy).to be_within(100).of(initial_orbit.to_car.vy)
    expect(propagated_car.vz).to be_within(100).of(initial_orbit.to_car.vz)
  end

  it "j2考慮ありの場合、高度400kmの円軌道の衛星を約1時間半に伝播させると1周より進むこと=J2ありの短い伝搬とJ2なしの長い伝搬が近くなること" do
    initial_orbit = Korba::Kep.new(
      object_name: "TestSat",
      epoch: Time.new(2026, 1, 1, 0, 0, 0),
      semi_major_axis: Korba::Constant::EARTH_RADIUS + 400_000,
      eccentricity: 0.0,
      inclination: 0.0,
      ra_of_asc_node: 0.0,
      arg_of_pericenter: 0.0,
      mean_anomaly: 0.0,
    )
    rk4 = Korba::Propagator::Rk4.new(initial_orbit.to_car)
    propagated_car = rk4.propagate(5538.14)
    rk4_disable_j2 = Korba::Propagator::Rk4.new(initial_orbit.to_car, disable_j2: true)
    propagated_car_disable_j2 = rk4_disable_j2.propagate(5553.62)

    expect(propagated_car.x).to be_within(100).of(propagated_car_disable_j2.x)
    # TODO: y軸の誤差が大きい
    expect(propagated_car.y).to be_within(10000).of(propagated_car_disable_j2.y)
    expect(propagated_car.z).to be_within(100).of(propagated_car_disable_j2.z)
    expect(propagated_car.vx).to be_within(100).of(propagated_car_disable_j2.vx)
    expect(propagated_car.vy).to be_within(100).of(propagated_car_disable_j2.vy)
    expect(propagated_car.vz).to be_within(100).of(propagated_car_disable_j2.vz)
  end
end
