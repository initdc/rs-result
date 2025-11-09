# frozen_string_literal: true

RSpec.describe(Rs::Result) do
  # https://doc.rust-lang.org/std/result/enum.Result.html

  it "has a version number" do
    expect(Rs::Result::VERSION).not_to be_nil
  end

  it "ok?" do
    x = Ok.new(-3)
    expect(x.ok?).to be true

    x = Err.new("Some error message")
    expect(x.ok?).to be false
  end

  it "ok_and" do
    x = Ok.new(2)
    expect(x.ok_and { |x| x > 1 }).to be true

    x = Ok.new(0)
    expect(x.ok_and { |x| x > 1 }).to be false

    x = Err.new("hey")
    expect(x.ok_and { |x| x > 1 }).to be false

    x = Ok.new("str")
    expect(x.ok_and { |x| x.size > 1 }).to be true
  end

  it "err?" do
    x = Ok.new(-3)
    expect(x.err?).to be false

    x = Err.new("Some error message")
    expect(x.err?).to be true
  end

  it "err_and" do
    x = Err.new(Errno::ENOENT)
    expect(x.err_and { |x| x == Errno::ENOENT }).to be true

    x = Err.new(Errno::EACCES)
    expect(x.err_and { |x| x == Errno::ENOENT }).to be false

    x = Ok.new(123)
    expect(x.err_and { |x| x == Errno::ENOENT }).to be false

    x = Err.new("str")
    expect(x.err_and { |x| x.size > 1 }).to be true
  end

  it "ok" do
    x = Ok.new(2)
    expect(x.ok).is_a?(Some)
    expect(x.unwrap).to eq 2

    x = Err.new("Nothing here")
    expect(x.ok).is_a?(None)
  end

  it "err" do
    x = Ok.new(2)
    expect(x.err).is_a?(None)

    x = Err.new("Nothing here")
    expect(x.err).is_a?(Some)
    expect(x.unwrap_err).to eq "Nothing here"
  end

  it "expect" do
    x = Err.new("emergency failure")
    expect { x.expect("Testing expect") }.to raise_error Rs::Result::UnwrapOnErr, "Testing expect: emergency failure"
  end

  it "unwrap" do
    x = Ok.new(2)
    expect(x.unwrap).to eq 2

    x = Err.new("emergency failure")
    expect {
      x.unwrap
    }.to raise_error Rs::Result::UnwrapOnErr, "called `Result::unwrap()` on an `Err` value: emergency failure"
  end

  it "unwrap_or default" do
    def parse_year(str)
      all_digit = true
      str.each_char do |c|
        if c < "0" || c > "9"
          all_digit = false
          break
        end
      end
      all_digit ? Ok.new(str.to_i) : Err.new("Not a year")
    end

    good_year_from_input = "1909"
    bad_year_from_input = "190blarg"
    good_year = parse_year(good_year_from_input).unwrap_or(0)
    bad_year = parse_year(bad_year_from_input).unwrap_or(0)

    expect(good_year).to eq 1909
    expect(bad_year).to eq 0
  end

  it "expect_err" do
    x = Ok.new(10)
    expect { x.expect_err("Testing expect_err") }.to raise_error Rs::Result::UnwrapErrOnOk, "Testing expect_err: 10"
  end

  it "unwrap_err" do
    x = Ok.new(2)
    expect {
      x.unwrap_err
    }.to raise_error Rs::Result::UnwrapErrOnOk, "called `Result::unwrap_err()` on an `Ok` value: 2"

    x = Err.new("emergency failure")
    expect(x.unwrap_err).to eq "emergency failure"
  end

  it "unwrap_or" do
    default = 2
    x = Ok.new(9)
    expect(x.unwrap_or(default)).to eq 9

    x = Err.new("error")
    expect(x.unwrap_or(default)).to eq default
  end

  it "unwrap_or_else" do
    expect(Ok.new(2).unwrap_or_else { |x| x.size }).to eq 2
    expect(Err.new("foo").unwrap_or_else { |x| x.size }).to eq 3
  end

  it "type ==" do
    a = Ok.new(1)
    b = Ok.new(1.0)
    c = Ok.new(1.0, type: Float)
    d = Ok.new("a")

    e = Err.new(1)
    f = Err.new(1.0)
    g = Err.new(1.0, type: Float)
    h = Err.new("a")
    i = Err.new(nil)

    expect(a == b).to be false
    expect(a == c).to be false
    expect(b == c).to be true
    expect(a == d).to be false

    expect(e == f).to be false
    expect(e == g).to be false
    expect(f == g).to be true
    expect(e == h).to be false
    expect(e == i).to be false
  end
end
