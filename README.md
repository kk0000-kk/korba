[![Gem Version](https://badge.fury.io/rb/korba.svg)](https://rubygems.org/gems/korba)

# Korba

An orbital analytics library for ruby.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add korba
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install korba
```

## Usage

### Create Orbital Elements From TLE(Two Line Elements)

```ruby
orbit = Korba::Tle.new(<<~TLE)
      ISS (ZARYA)
      1 25544U 98067A   24342.85930654  .00018474  00000+0  32681-3 0  9991
      2 25544  51.6381 174.9565 0006817 314.0303 175.4461 15.50337242485488
    TLE

orbit.semi_major_axis
# => 6793877.649839985

orbit.height_at_perigee
# => 411109.2634460889

orbit.height_at_apogee
# => 420372.03623388056

kep = orbit.to_kep
# =>
# #<Korba::Kep:xxxxxxxxxxxxxxxx
#  @arg_of_pericenter=314.0303,
#  @eccentricity=0.0006817,
#  @epoch="2024-12-07T20:37:24.085055",
#  @inclination=51.6381,
#  @mean_anomaly=175.4461,
#  @object_name="ISS (ZARYA)",
#  @ra_of_asc_node=174.9565,
#  @semi_major_axis=6793877.649839985>

kep.to_car
# =>
# #<Korba::Car:xxxxxxxxxxxxxxxx
#  @epoch="2024-12-07T20:37:24.085055",
#  @object_name="ISS (ZARYA)",
#  @vx=6150.772410883998,
#  @vy=2489.3298780751356,
#  @vz=-3816.0301666253677,
#  @x=4019753.8621700387,
#  @y=-3623966.518673545,
#  @z=4114361.6934797494>

```

## References

- 宇宙工学シリーズ 3 人工衛星と宇宙探査機
  - https://www.coronasha.co.jp/np/isbn/9784339012316/
- 人工衛星の軌道 概論
  - https://www.coronasha.co.jp/np/isbn/9784339046403/

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kk0000-kk/korba.
