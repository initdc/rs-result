# frozen_string_literal: true

class T
  def initialize(value)
    @value = value
  end

  def inspect
    "T[#{@value.class}]"
  end
end

class TE
  def initialize(value, error)
    @value = value
    @error = error
  end

  def inspect
    "TE[#{@value.class}, #{@error.class}]"
  end
end

# p T.new(0)
# p TE.new(0, "a")

# p = Proc.new { |x| p x }
# l = lambda { |x| p x }
# a1 = -> (x) { p x }

# a1.(6, 0)
