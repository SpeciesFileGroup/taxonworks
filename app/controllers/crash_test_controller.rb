class CrashTestController < ApplicationController

  def index
    a = 1
    b = a - 1
    c = 2 * b
    c / (a * b)
  end

end
