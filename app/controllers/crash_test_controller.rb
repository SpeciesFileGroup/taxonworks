class CrashTestController < ApplicationController
  def index
    a, b, c = 0, 1, 2
    b / a # 1/0
  end
end
