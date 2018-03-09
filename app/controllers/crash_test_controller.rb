class CrashTestController < ApplicationController

  def index
    a = 1 - 1 # zero
    b = a + 1 # one
    c = b + b # two
    index_zero((c - (2 * b)), (b - 0.1))
  end

  private

# @param [Integer] zip
# @param [Float] nada
# @return [Float]
  def index_zero(zip, nada)
    return (nada / zip)
  end

end
