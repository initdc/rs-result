# frozen_string_literal: true

require_relative "option"
require_relative "result/version"

module Rs
  # https://doc.rust-lang.org/std/result/index.html
  # https://doc.rust-lang.org/std/result/enum.Result.html
  # https://doc.rust-lang.org/src/core/result.rs.html
  module Result
    class ArgumentError < StandardError; end
    class UnwrapOnErr < StandardError; end
    class UnwrapErrOnOk < StandardError; end
    class TypeError < StandardError; end

    def ok?
      @ok
    end

    def ok_and
      if !@ok
        false
      elsif block_given?
        yield(@value)
      else
        @ok
      end
    end

    def err?
      !@ok
    end

    def err_and
      if @ok
        false
      elsif block_given?
        yield(@value)
      else
        !@ok
      end
    end

    def ok
      if @ok
        Some.new(@value)
      else
        None.new
      end
    end

    def err
      if !@ok
        Some.new(@value)
      else
        None.new
      end
    end

    def expect(msg)
      @ok ? @value : raise(UnwrapOnErr, "#{msg}: #{@value}")
    end

    def unwrap
      @ok ? @value : raise(UnwrapOnErr, "called `Result::unwrap()` on an `Err` value: #{@value}")
    end

    def unwrap_or(default = nil)
      if @ok
        @value
      elsif block_given?
        yield
      else
        default
      end
    end

    def unwrap_or_else(&block)
      @ok ? @value : block.call(@value)
    end

    def expect_err(msg)
      @ok ? raise(UnwrapErrOnOk, "#{msg}: #{@value}") : @value
    end

    def unwrap_err
      @ok ? raise(UnwrapErrOnOk, "called `Result::unwrap_err()` on an `Ok` value: #{@value}") : @value
    end
  end
end

class Ok
  include Rs::Result

  attr_reader :type
  attr_reader :ok
  attr_reader :value

  private :value

  def initialize(value, type: nil)
    if value == nil
      raise(Rs::Result::ArgumentError, "Ok value cannot be nil")
    end

    if type
      if value.class != type
        raise(Rs::Result::TypeError, "Value type #{value.class} does not match #{type}")
      end

      @type = type
    else
      @type = value.class
    end

    @ok = true
    @value = value
  end

  def ==(other)
    other.is_a?(Ok) && @type == other.type && @value == other.unwrap
  end
end

class Err
  include Rs::Result

  attr_reader :type
  attr_reader :ok
  attr_reader :value

  private :value

  def initialize(error, type: nil)
    if type
      if error.class != type
        raise(Rs::Result::TypeError, "Error type #{error.class} does not match #{type}")
      end

      @type = type
    else
      @type = error.class
    end

    @ok = false
    @value = error
  end

  def ==(other)
    other.is_a?(Err) && @type == other.type && @value == other.unwrap_err
  end
end
