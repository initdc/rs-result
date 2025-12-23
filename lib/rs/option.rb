# frozen_string_literal: true

require_relative "result/version"
module Rs
  # https://doc.rust-lang.org/std/option/index.html
  # https://doc.rust-lang.org/std/option/enum.Option.html
  # https://doc.rust-lang.org/src/core/option.rs.html
  class Option
    class TypeError < StandardError
      def initialize(type)
        super("Expected #{type} to be a Class")
      end
    end

    class TypeNilClass < StandardError; end
    class TypeMismatch < StandardError; end
    class WrapNil < StandardError; end
    class UnwrapNone < StandardError; end

    def is_some
      is_a?(Some)
    end

    def is_some_and(&block)
      is_some ? block.call(@value) : false
    end

    def is_none
      is_a?(None)
    end

    def is_none_or(&block)
      is_none ? true : block.call(@value)
    end

    def expect(msg)
      is_some ? @value : raise(UnwrapNone.new(msg))
    end

    def unwrap
      is_some ? @value : raise(UnwrapNone.new("Called unwrap on None"))
    end

    def unwrap_or(default)
      is_some ? @value : default
    end

    def unwrap_or_else(&block)
      is_some ? @value : block.call
    end
  end
end

class Some < Rs::Option
  def self.[](type, &block)
    if !type.is_a?(Class)
      raise TypeError.new(type)
    end

    if type == NilClass
      raise TypeNilClass.new("Cannot create Some[T] with NilClass")
    end

    value = block.call
    if !value.is_a?(type)
      raise TypeMismatch.new("Expected 'Some[#{type}] { #{value.inspect} }' block.call to be #{type}, not #{value.class}")
    end

    new(value)
  end

  def inspect
    "Some[#{@value.class}] { #{@value.inspect} }"
  end

  def ==(other)
    other.is_a?(Some) && @value == other.unwrap && @value.class == other.unwrap.class
  end

  def initialize(value)
    if value == nil
      raise WrapNil.new("Cannot create Some[T](value) with nil")
    end

    @value = value
  end
end

class None < Rs::Option
  attr_reader :type

  def self.[](type)
    new(type)
  end

  def inspect
    "None[#{@type}]"
  end

  def ==(other)
    other.is_a?(None) && @type == other.type
  end

  def initialize(type = Class)
    if !type.is_a?(Class)
      raise TypeError.new(type)
    end

    if type == NilClass
      raise TypeNilClass.new("Cannot create None[T] with NilClass")
    end

    @type = type
  end
end
