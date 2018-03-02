class Tasks::BrowseAnnotationsController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index

  end

  def get_type

  end

  def process_submit
    render({json: params})
  end

end