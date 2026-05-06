# frozen_string_literal: true

RSpec.describe Korba::Car do
  describe "#to_kep" do
    car = Korba::Car.new(
      object_name: "ISS (ZARYA)",
      epoch: Time.new("2024-12-07T20:37:24.085056 UTC"),
      x: 4019753.862,
      y: -3623966.519,
      z: 4114361.693,
      vx: 6150.772,
      vy: 2489.330,
      vz: -3816.030,
    )

    it "can transform to kep" do
      kep = car.to_kep
      expect(kep.object_name).to eq("ISS (ZARYA)")
      expect(kep.epoch).to eq(Time.new("2024-12-07T20:37:24.085056 UTC"))
      expect(kep.semi_major_axis).to be_within(100).of(6793877.649839985)
      expect(kep.eccentricity).to be_within(0.0000001).of(0.0006817)
      expect(kep.inclination).to be_within(0.0001).of(51.6381)
      expect(kep.ra_of_asc_node).to be_within(0.0001).of(174.9565)
      expect(kep.arg_of_pericenter).to be_within(0.01).of(314.0303)
      expect(kep.mean_anomaly).to be_within(0.01).of(175.4461)
    end
  end
end
