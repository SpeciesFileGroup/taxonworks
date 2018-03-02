class Tasks::BrowseAnnotationsController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index

  end

  def get_type
    render({json: params})
  end

  def annotation_on

  end

  def annotation_for

  end

  def process_submit
    render({json: params})
  end

  def set_model
    render({json: params})
  end

  def get_dates

  end

  def get_logic

  end
end