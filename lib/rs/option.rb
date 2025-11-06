# frozen_string_literal: true

require_relative "result/version"
module Rs
  # https://doc.rust-lang.org/std/option/index.html
  # https://doc.rust-lang.org/std/option/enum.Option.html
  # https://doc.rust-lang.org/src/core/option.rs.html
  module Option
    class ArgumentError < StandardError; end
    class UnwrapNone < StandardError; end

    def some?
      @some
    end

    def some_and
      if !@some
        false
      elsif block_given?
        yield(@value)
      else
        @some
      end
    end

    def none?
      !@some
    end

    def none_or
      if !@some
        true
      elsif block_given?
        yield(@value)
      else
        !@some
      end
    end

    def expect(msg)
      @some ? @value : raise(UnwrapNone, msg)
    end

    def unwrap
      @some ? @value : raise(UnwrapNone)
    end

    def unwrap_or(default = nil)
      if @some
        @value
      elsif block_given?
        yield
      else
        default
      end
    end

    def unwrap_or_else(&block)
      @some ? @value : block.call
    end
  end
end

class Some
  include Rs::Option

  def initialize(value)
    if value == nil
      raise(Rs::Option::ArgumentError, "Some value cannot be nil")
    end

    @value = value
    @some = true
  end
end

class None
  include Rs::Option

  def initialize
    @some = false
  end
end
