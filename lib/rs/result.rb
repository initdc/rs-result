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
  def initialize(value)
    if value == nil
      raise(Rs::Result::ArgumentError, "Ok value cannot be nil")
    end

    @value = value
    @ok = true
  end
end

class Err
  include Rs::Result
  def initialize(error)
    @value = error
    @ok = false
  end
end
