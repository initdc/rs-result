# frozen_string_literal: true

RSpec.describe Rs::Option do
  # https://doc.rust-lang.org/std/option/enum.Option.html

  it "new" do
    expect { Some.new(nil) }.to raise_error Rs::Option::ArgumentError, "Some value cannot be nil"
  end

  it "some?" do
    x = Some.new(2)
    expect(x.some?).to be true

    x = None.new
    expect(x.some?).to be false
  end

  it "some_and proc" do
    x = Some.new(2)
    expect(x.some_and).to be true
    expect(x.some_and { |x| x > 1 }).to be true

    x = Some.new(0)
    expect(x.some_and { |x| x > 1 }).to be false

    x = None.new
    expect(x.some_and { |x| x.to_i > 1 }).to be false

    x = Some.new("str")
    expect(x.some_and { |x| x.size > 1 }).to be true
  end

  it "none?" do
    x = Some.new(2)
    expect(x.none?).to be false

    x = None.new
    expect(x.none?).to be true
  end

  it "none_or proc" do
    x = Some.new(2)
    expect(x.none_or).to be false
    expect(x.none_or { |x| x > 1 }).to be true

    x = Some.new(0)
    expect(x.none_or { |x| x > 1 }).to be false

    x = None.new
    expect(x.none_or { |x| x.to_i > 1 }).to be true

    x = Some.new("str")
    expect(x.none_or { |x| x.size > 1 }).to be true
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

  it "unwrap_or proc" do
    k = 10
    expect(Some.new(4).unwrap_or { 2 * k }).to eq 4
    expect(None.new.unwrap_or { 2 * k }).to eq 20
  end

  it "unwrap_or_else proc" do
    k = 10
    expect(Some.new(4).unwrap_or_else { 2 * k }).to eq 4
    expect(None.new.unwrap_or_else { 2 * k }).to eq 20
  end

  it "unwrap_or default" do
    x = None.new
    y = Some.new(12)

    expect(x.unwrap_or).to be_nil
    expect(y.unwrap_or).to eq 12
  end
end
