# frozen_string_literal: true

RSpec.describe Korba::Propagator::Kepler do
  it "高度400kmの軌道を伝搬して1周させる(J2考慮なしは形は変わらない)" do
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
    kepler_propagator = Korba::Propagator::Kepler.new(initial_orbit, disable_j2: true)
    propagated_kep = kepler_propagator.propagate(5554)

    expect(propagated_kep.object_name).to eq(initial_orbit.object_name)
    expect(propagated_kep.epoch).to eq(Time.new(2026, 1, 1, 1, 32, 34))
    expect(propagated_kep.semi_major_axis).to eq(initial_orbit.semi_major_axis)
    expect(propagated_kep.eccentricity).to eq(initial_orbit.eccentricity)
    expect(propagated_kep.inclination).to eq(initial_orbit.inclination)
    expect(propagated_kep.ra_of_asc_node).to eq(initial_orbit.ra_of_asc_node)
    expect(propagated_kep.arg_of_pericenter).to eq(initial_orbit.arg_of_pericenter)
    expect(propagated_kep.mean_anomaly).to be_within(0.1).of(initial_orbit.mean_anomaly)
  end
it "高度400kmの軌道を伝搬して1周させる" do
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
    kepler_propagator = Korba::Propagator::Kepler.new(initial_orbit)
    propagated_kep = kepler_propagator.propagate(5554)

    expect(propagated_kep.object_name).to eq(initial_orbit.object_name)
    expect(propagated_kep.epoch).to eq(Time.new(2026, 1, 1, 1, 32, 34))
    expect(propagated_kep.semi_major_axis).to eq(initial_orbit.semi_major_axis)
    expect(propagated_kep.eccentricity).to eq(initial_orbit.eccentricity)
    expect(propagated_kep.inclination).to eq(initial_orbit.inclination)
    expect(propagated_kep.ra_of_asc_node).to be_within(0.01).of(359.48)
    expect(propagated_kep.arg_of_pericenter).to be_within(0.001).of(1.0354)
    expect(propagated_kep.mean_anomaly).to be_within(0.1).of(initial_orbit.mean_anomaly)
  end
end
