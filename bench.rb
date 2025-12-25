# frozen_string_literal: true

require "benchmark/ips"
require_relative "lib/rs/types"

n = 1000

Benchmark.ips do |x|
  x.config(warmup: 2, time: 1)

  x.report("Some[]") do
    n.times do
      Some[Integer] { 0 }
    end
  end

  x.report("Some.new") do
    n.times do
      Some.new(0)
    end
  end

  x.report("None[]") do
    n.times do
      None[Integer]
    end
  end

  x.report("None.new") do
    n.times do
      None.new
    end
  end

  x.compare!
end

Benchmark.ips do |x|
  x.config(warmup: 2, time: 1)

  x.report("Ok[]") do
    n.times do
      Ok[Integer, Integer] { 0 }
    end
  end

  x.report("Ok.new") do
    n.times do
      Ok.new(0)
    end
  end

  x.report("Err[]") do
    n.times do
      Err[Integer, Integer] { 0 }
    end
  end

  x.report("Err.new") do
    n.times do
      Err.new(0)
    end
  end

  x.compare!
end
