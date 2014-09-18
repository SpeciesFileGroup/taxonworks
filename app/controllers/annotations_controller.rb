class AnnotationsController < ApplicationController
  # todo: @mjyis this required? Some of what it does would be redundant, if this controller is
  # used only for a partial
  # include DataControllerConfiguration

  def new_alternate_values
    @object    = Serial.first
    # todo: will be expanded to any attribute of any project(?)
    @attribute = @object.name
  end

  def create_alternate_values

  end

end
