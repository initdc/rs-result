# frozen_string_literal: true

require_relative "result/version"

module Rs
  # https://doc.rust-lang.org/std/result/index.html
  # https://doc.rust-lang.org/std/result/enum.Result.html
  # https://doc.rust-lang.org/src/core/result.rs.html
  class Result
    class TypeError < StandardError
      def initialize(value_type, error_type)
        super("Expected #{value_type} or #{error_type} to be a Class")
      end
    end

    class TypeNilClass < StandardError; end
    class TypeMismatch < StandardError; end
    class WrapNil < StandardError; end
    class UnwrapOnErr < StandardError; end
    class UnwrapErrOnOk < StandardError; end

    def is_ok
      is_a?(Ok)
    end

    def is_ok_and(&block)
      is_ok ? block.call(@value) : false
    end

    def is_err
      is_a?(Err)
    end

    def is_err_and(&block)
      is_err ? block.call(@error) : false
    end

    def ok
      is_ok ? Some[@value_type] { @value } : None[@value_type]
    end

    def err
      is_err ? Some[@error_type] { @error } : None[@error_type]
    end

    def expect(msg)
      is_ok ? @value : raise(UnwrapOnErr.new("#{msg}: #{@error}"))
    end

    def unwrap
      is_ok ? @value : raise(UnwrapOnErr.new("called unwrap on an Err value: #{@error}"))
    end

    def unwrap_or(default)
      is_ok ? @value : default
    end

    def unwrap_or_else(&block)
      is_ok ? @value : block.call(@error)
    end

    def expect_err(msg)
      is_ok ? raise(UnwrapErrOnOk.new("#{msg}: #{@value}")) : @error
    end

    def unwrap_err
      is_ok ? raise(UnwrapErrOnOk.new("called unwrap_err() on an Ok value: #{@value}")) : @error
    end
  end
end

class Ok < Rs::Result
  attr_accessor :value_type
  attr_accessor :error_type

  def self.[](value_type, error_type, &block)
    if !value_type.is_a?(Class) || !error_type.is_a?(Class)
      raise TypeError.new(value_type, error_type)
    end

    if value_type == NilClass || error_type == NilClass
      raise TypeNilClass.new("Cannot create Ok[T, E] with [#{value_type}, #{error_type}]")
    end

    value = block.call
    if !value.is_a?(value_type)
      raise TypeMismatch.new("Expected 'Ok[#{value_type}, #{error_type}] { #{value.inspect} }' block.call to be #{value_type}, not #{value.class}")
    end

    if value == nil
      raise WrapNil.new("Cannot create Ok[#{value_type}, #{error_type}] with nil")
    end

    ok_instance = Ok.new(value)
    ok_instance.error_type = error_type
    ok_instance
  end

  def inspect
    "Ok[#{@value_type}, #{@error_type}] { #{@value.inspect} }"
  end

  def ==(other)
    other.is_a?(Ok) && @value == other.unwrap && @value_type == other.value_type && @error_type == other.error_type
  end

  def initialize(value)
    if value == nil
      raise WrapNil.new("Cannot create Ok[T, E] with nil")
    end

    @value = value
    @value_type = value.class
    @error_type = Class
  end
end

class Err < Rs::Result
  attr_accessor :value_type
  attr_accessor :error_type

  def self.[](value_type, error_type, &block)
    if !value_type.is_a?(Class) || !error_type.is_a?(Class)
      raise TypeError.new(value_type, error_type)
    end

    if value_type == NilClass || error_type == NilClass
      raise TypeNilClass.new("Cannot create Err[T, E] with [#{value_type}, #{error_type}]")
    end

    error = block.call
    if !error.is_a?(error_type)
      raise TypeMismatch.new("Expected 'Err[#{value_type}, #{error_type}] { #{error.inspect} }' block.call to be #{error_type}, not #{error.class}")
    end

    if error == nil
      raise WrapNil.new("Cannot create Err[#{value_type}, #{error_type}] with nil")
    end

    err_instance = Err.new(error)
    err_instance.value_type = value_type
    err_instance
  end

  def inspect
    "Err[#{@value_type}, #{@error_type}] { #{@error.inspect} }"
  end

  def ==(other)
    other.is_a?(Err) && @error == other.unwrap_err && @value_type == other.value_type && @error_type == other.error_type
  end

  def initialize(error)
    if error == nil
      raise WrapNil.new("Cannot create Err[T, E] with nil")
    end

    @error = error
    @error_type = error.class
    @value_type = Class
  end
end
