# frozen_string_literal: true
require "bigdecimal/newton"
include Newton

module Korba
  class NewtonFunction
    def initialize()
      @zero = BigDecimal("0.0")
      @one = BigDecimal("1.0")
      @two = BigDecimal("2.0")
      @ten = BigDecimal("10.0")
      @eps = BigDecimal("1.0e-14")
    end

    def zero; @zero; end
    def one; @one; end
    def two; @two; end
    def ten; @ten; end
    def eps; @eps; end

    def values(x)
      raise NotImplementedError
    end
  end
end
