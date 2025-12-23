# frozen_string_literal: true

RSpec.describe Rs::Option do
  # https://doc.rust-lang.org/std/option/enum.Option.html

  it "new" do
    expect { Some[nil] {} }.to raise_error Rs::Option::TypeError
    expect { Some[NilClass] { nil } }.to raise_error Rs::Option::TypeNilClass
    expect { Some[Integer] { nil } }.to raise_error Rs::Option::TypeMismatch
    expect { Some.new(nil) }.to raise_error Rs::Option::WrapNil

    expect { None[nil] }.to raise_error Rs::Option::TypeError
    expect { None[NilClass] }.to raise_error Rs::Option::TypeNilClass
    expect { None.new(nil) }.to raise_error Rs::Option::TypeError
    expect { None.new(NilClass) }.to raise_error Rs::Option::TypeNilClass

    x = Some.new(2)
    y = Some[Integer] { 2 }
    expect(x).to eq y

    x = None.new(Integer)
    y = None[Integer]
    expect(x).to eq y

    x = None.new
    y = None[Class]
    expect(x).to eq y
  end

  it "is_some" do
    x = Some.new(2)
    expect(x.is_some).to be true

    x = None.new
    expect(x.is_some).to be false
  end

  it "is_some_and" do
    x = Some.new(2)
    expect(x.is_some_and { |x| x > 1 }).to be true

    x = Some.new(0)
    expect(x.is_some_and { |x| x > 1 }).to be false

    x = None.new
    expect(x.is_some_and { |x| x.to_i > 1 }).to be false

    x = Some.new("str")
    expect(x.is_some_and { |x| x.size > 1 }).to be true
  end

  it "is_none" do
    x = Some.new(2)
    expect(x.is_none).to be false

    x = None.new
    expect(x.is_none).to be true
  end

  it "is_none_or" do
    x = Some.new(2)
    expect(x.is_none_or { |x| x > 1 }).to be true

    x = Some.new(0)
    expect(x.is_none_or { |x| x > 1 }).to be false

    x = None.new
    expect(x.is_none_or { |x| x.to_i > 1 }).to be true

    x = Some.new("str")
    expect(x.is_none_or { |x| x.size > 1 }).to be true
  end

  it "expect" do
    x = Some.new("air")
    expect(x.expect("no air")).to eq "air"

    x = None.new
    expect { x.expect("no air") }.to raise_error Rs::Option::UnwrapNone
  end

  it "unwrap" do
    x = Some.new("air")
    expect(x.unwrap).to eq "air"

    x = None.new
    expect { x.unwrap }.to raise_error Rs::Option::UnwrapNone
  end

  it "unwrap_or" do
    expect(Some.new("car").unwrap_or("bike")).to eq "car"
    expect(None.new.unwrap_or("bike")).to eq "bike"
  end

  it "unwrap_or_else" do
    k = 10
    expect(Some.new(4).unwrap_or_else { 2 * k }).to eq 4
    expect(None.new.unwrap_or_else { 2 * k }).to eq 20
  end

  it "unwrap_or default" do
    x = None.new
    y = Some.new(12)

    expect(x.unwrap_or(0)).to eq 0
    expect(y.unwrap_or(0)).to eq 12
  end

  it "pattern_matching" do
    def divide(numerator, denominator)
      if denominator == 0
        None[Float]
      else
        Some[Float] { numerator / denominator }
      end
    end

    result = divide(3.0, 1.0)
    case result
    when Some
      x = result.unwrap
    else
      x = "Cannot divide by 0"
    end
    expect(x).to eq 3.0
  end

  it "type ==" do
    a = Some.new(1)
    b = Some.new(1.0)
    c = Some[Float] { 1.0 }
    d = Some.new("a")
    e = None.new

    expect(a == b).to be false
    expect(a == c).to be false
    expect(b == c).to be true
    expect(a == d).to be false
    expect(a == e).to be false
  end

  it "map" do
    x = Some.new("hello")
    expect(x.map(Integer) { |x| x.size }).to eq Some.new(5)

    y = None.new(String)
    expect(y.map(Integer) { |x| x.size }).to eq None[Integer]
  end

  it "tap" do
    x = Some.new(2)
    y = None.new

    result = []
    x.tap { |v| result << v }
    y.tap { |v| result << v }

    expect(result).to eq [2]
    expect(x.tap {}).to eq Some.new(2)
    expect(y.tap {}).to eq None.new
  end

  it "map_or" do
    x = Some.new("foo")
    expect(x.map_or(42) { |x| x.size }).to eq 3

    y = None.new(String)
    expect(y.map_or(42) { |x| x.size }).to eq 42
  end

  it "map_or_else" do
    k = 21
    x = Some.new("foo")
    expect(x.map_or_else(lambda { 2 * k }) { |x| x.size }).to eq 3

    y = None.new(String)
    expect(y.map_or_else(lambda { 2 * k }) { |x| x.size }).to eq 42
  end

  it "ok_or" do
    x = Some.new("foo")
    y = None[String]

    expect(x.ok_or(0)).to eq Ok[String, Integer] { "foo" }
    expect(y.ok_or(0)).to eq Err[String, Integer] { 0 }
  end

  it "ok_or_else" do
    x = Some.new("foo")
    y = None[String]

    expect(x.ok_or_else { 0 }).to eq Ok[String, Integer] { "foo" }
    expect(y.ok_or_else { 0 }).to eq Err[String, Integer] { 0 }
  end

  it "and" do
    x = Some.new(2)
    y = None[Integer]

    expect(x.and(Some.new("foo"))).to eq Some.new("foo")
    expect(y.and(Some.new("foo"))).to eq None[String]
  end

  it "and_then" do
    x = Some.new(2)
    y = None[Integer]

    expect(x.and_then(String) { |x| Some.new(x.to_s) }).to eq Some.new("2")
    expect(y.and_then(String) { |x| Some.new(x.to_s) }).to eq None[String]
  end

  it "select" do
    x = Some.new(2)
    y = Some.new(0)
    z = None.new

    expect(x.select { |x| x > 1 }).to eq x
    expect(y.select { |x| x > 1 }).to eq None[Integer]
    expect(z.select { |x| x > 1 }).to eq None.new
  end

  it "or" do
    x = Some.new(2)
    y = None.new

    expect(x.or(Some.new(100))).to eq x
    expect(y.or(Some.new(100))).to eq Some.new(100)
  end

  it "or_else" do
    x = Some.new(2)
    y = None.new

    expect(x.or_else { Some.new(100) }).to eq x
    expect(y.or_else { Some.new(100) }).to eq Some.new(100)
  end

  it "xor" do
    x = Some.new(2)
    y = None[Integer]
    z = Some.new(100)

    expect(x.xor(y)).to eq x
    expect(y.xor(x)).to eq x
    expect(x.xor(z)).to eq None[Integer]
    expect(y.xor(None[Integer])).to eq None[Integer]
  end

  it "from" do
    x = described_class.from(Integer) { 2 }
    expect(x).to eq Some.new(2)
  end

  it "from?" do
    x = described_class.from?(Integer) { 2 }
    y = described_class.from?(Integer) {}

    expect(x).to eq Some.new(2)
    expect(y).to eq None[Integer]
  end

  it "from!" do
    x = described_class.from!(Integer) { 2 }
    y = described_class.from!(Integer) { RuntimeError.new("Error") }

    expect(x).to eq Some.new(2)
    expect(y).to eq None[Integer]
  end
end
