# frozen_string_literal: true

module Korba
  class Car
    attr_reader :object_name, :epoch, :x, :y, :z, :vx, :vy, :vz

    def initialize(object_name:, epoch:, x:, y:, z:, vx:, vy:, vz:)
      @object_name = object_name
      @epoch = epoch
      @x = x
      @y = y
      @z = z
      @vx = vx
      @vy = vy
      @vz = vz
    end
  end
end
