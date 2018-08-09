class Tasks::Uniquify::PeopleController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @people = Person.none
  end
  
end
