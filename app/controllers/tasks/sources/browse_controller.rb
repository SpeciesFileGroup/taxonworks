class Tasks::Sources::BrowseController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @sources = []
  end

  # GET
  def find
    @sources = Source.all.limit(10)
    render :index
  end

end
