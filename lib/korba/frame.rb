module Korba
  module Frame
    Definition = Data.define(:center, :orientation, :base)

    ECI_J2000 = Definition.new(center: :earth, orientation: :j2000, base: :inertial)
    ECI_TEME = Definition.new(center: :earth, orientation: :teme, base: :inertial)
    ECEF = Definition.new(center: :earth, orientation: :itrf, base: :fixed)
  end
end
