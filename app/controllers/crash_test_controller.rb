class CrashTestController < ApplicationController
  def index
    1/0
  end
end
