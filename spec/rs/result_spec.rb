# frozen_string_literal: true

RSpec.describe(Rs::Result) do
  # https://doc.rust-lang.org/std/result/enum.Result.html

  it "has a version number" do
    expect(Rs::Result::VERSION).not_to be_nil
  end

  it "new" do
    expect { Ok[nil, nil] {} }.to raise_error Rs::Result::TypeError
    expect { Ok[NilClass, NilClass] { nil } }.to raise_error Rs::Result::TypeNilClass
    expect { Ok[Integer, Integer] { nil } }.to raise_error Rs::Result::TypeMismatch
    expect { Ok.new(nil) }.to raise_error Rs::Result::WrapNil

    expect { Err[nil, nil] {} }.to raise_error Rs::Result::TypeError
    expect { Err[NilClass, NilClass] { nil } }.to raise_error Rs::Result::TypeNilClass
    expect { Err[Integer, Integer] { nil } }.to raise_error Rs::Result::TypeMismatch
    expect { Err.new(nil) }.to raise_error Rs::Result::WrapNil
  end

  it "is_ok" do
    x = Ok.new(-3)
    expect(x.is_ok).to be true

    x = Err.new("Some error message")
    expect(x.is_ok).to be false
  end

  it "is_ok_and" do
    x = Ok.new(2)
    expect(x.is_ok_and { |x| x > 1 }).to be true

    x = Ok.new(0)
    expect(x.is_ok_and { |x| x > 1 }).to be false

    x = Err.new("hey")
    expect(x.is_ok_and { |x| x > 1 }).to be false

    x = Ok.new("str")
    expect(x.is_ok_and { |x| x.size > 1 }).to be true
  end

  it "is_err" do
    x = Ok.new(-3)
    expect(x.is_err).to be false

    x = Err.new("Some error message")
    expect(x.is_err).to be true
  end

  it "is_err_and" do
    x = Err.new(Errno::ENOENT)
    expect(x.is_err_and { |x| x == Errno::ENOENT }).to be true

    x = Err.new(Errno::EACCES)
    expect(x.is_err_and { |x| x == Errno::ENOENT }).to be false

    x = Ok.new(123)
    expect(x.is_err_and { |x| x == Errno::ENOENT }).to be false

    x = Err.new("str")
    expect(x.is_err_and { |x| x.size > 1 }).to be true
  end

  it "ok" do
    x = Ok.new(2)

    expect(x.ok).to eq Some.new(2)
    expect(x.unwrap).to eq 2

    x = Err.new("Nothing here")
    expect(x.ok).to eq None.new

    x = Ok[Float, String] { 1.0 }
    expect(x.ok).to eq Some[Float] { 1.0 }

    x = Err[Float, String] { "foo" }
    expect(x.ok).to eq None[Float]
  end

  it "err" do
    x = Ok.new(2)
    expect(x.err).to eq None.new

    x = Err.new("Nothing here")
    expect(x.err).to eq Some.new("Nothing here")
    expect(x.unwrap_err).to eq "Nothing here"

    x = Ok[Float, String] { 1.0 }
    expect(x.err).to eq None[String]

    x = Err[Float, String] { "foo" }
    expect(x.err).to eq Some[String] { "foo" }
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
    }.to raise_error Rs::Result::UnwrapOnErr
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
    expect { x.expect_err("Testing expect_err") }.to raise_error Rs::Result::UnwrapErrOnOk
  end

  it "unwrap_err" do
    x = Ok.new(2)
    expect {
      x.unwrap_err
    }.to raise_error Rs::Result::UnwrapErrOnOk

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
    c = Ok[Float, Class] { 1.0 }
    d = Ok.new("a")

    e = Err.new(1)
    f = Err.new(1.0)
    g = Err[Class, Float] { 1.0 }
    h = Err.new("a")

    expect(a == b).to be false
    expect(a == c).to be false
    expect(b == c).to be true
    expect(a == d).to be false

    expect(e == f).to be false
    expect(e == g).to be false
    expect(f == g).to be true
    expect(e == h).to be false
  end
end
