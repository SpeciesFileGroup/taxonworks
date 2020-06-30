class CrashTestController < ApplicationController

  def index
    User.create!
  end

end
