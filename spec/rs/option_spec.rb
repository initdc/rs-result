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

  it "is_some_and proc" do
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

  it "is_none_or proc" do
    x = Some.new(2)
    expect(x.is_none_or { |x| x > 1 }).to be true

    x = Some.new(0)
    expect(x.is_none_or { |x| x > 1 }).to be false

    x = None.new
    expect(x.is_none_or { |x| x.to_i > 1 }).to be true

    x = Some.new("str")
    expect(x.is_none_or { |x| x.size > 1 }).to be true
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

  it "unwrap_or_else proc" do
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
        None.new
      else
        Some.new(numerator / denominator)
      end
    end

    result = divide(3, 1)
    case result
    when Some
      x = result.unwrap
    else
      x = "Cannot divide by 0"
    end
    expect(x).to eq 3
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
end
