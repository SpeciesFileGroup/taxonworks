class Tasks::Unify::PeopleController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @people = Person.none
  end
  
end
