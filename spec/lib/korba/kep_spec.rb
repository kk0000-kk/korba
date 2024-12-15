# frozen_string_literal: true

RSpec.describe Korba::Kep do
  kep = Korba::Kep.new(
    object_name: "ISS (ZARYA)",
    eccentricity: 0.0006817,
    inclination: 51.6381,
    ra_of_asc_node: 174.9565,
    arg_of_pericenter: 314.0303,
    mean_anomaly: 175.4461,
    epoch: "2024-12-07T20:37:24.085056",
    semi_major_axis: 6793877.649839985,
  )

  it "can calculate eccentric anomaly" do
    expect(kep.eccentric_anomaly).to be_within(0.00001).of(175.44919)
  end

  it "can calculate distance (r)" do
    expect(kep.distance).to be_within(0.00001).of(6798494.43521)
  end

  it "can calculate velocity" do
    expect(kep.velocity).to be_within(0.00001).of(7654.46606)
  end

  it "can calculate true anomaly" do
    expect(kep.true_anomaly).to be_within(0.00001).of(175.45229)
  end

  it "can transform to car" do
    car = kep.to_car
    expect(car.x).to be_within(0.001).of(4019753.862)
    expect(car.y).to be_within(0.001).of(-3623966.519)
    expect(car.z).to be_within(0.001).of(4114361.693)
    expect(car.vx).to be_within(0.001).of(6150.772)
    expect(car.vy).to be_within(0.001).of(2489.330)
    expect(car.vz).to be_within(0.001).of(-3816.030)
  end
end
