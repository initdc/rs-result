# frozen_string_literal: true

require_relative "result/version"
module Rs
  # https://doc.rust-lang.org/std/option/index.html
  # https://doc.rust-lang.org/std/option/enum.Option.html
  # https://doc.rust-lang.org/src/core/option.rs.html
  module Option
    class ArgumentError < StandardError; end
    class UnwrapNone < StandardError; end
    class TypeError < StandardError; end

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

  attr_reader :type
  attr_reader :some
  attr_reader :value

  private :value

  def initialize(value, type: nil)
    if value == nil
      raise(Rs::Option::ArgumentError, "Some value cannot be nil")
    end

    if type
      if value.class != type
        raise(Rs::Option::TypeError, "Value type #{value.class} does not match #{type}")
      end

      @type = type
    else
      @type = value.class
    end

    @some = true
    @value = value
  end

  def ==(other)
    other.is_a?(Some) && @type == other.type && @value == other.unwrap
  end
end

class None
  include Rs::Option

  attr_reader :type
  attr_reader :some
  attr_reader :value

  private :value

  def initialize
    @type = NilClass
    @some = false
    @value = nil
  end

  def ==(other)
    other.is_a? None
  end
end
