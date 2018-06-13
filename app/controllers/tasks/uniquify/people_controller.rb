class Tasks::Uniquify::PeopleController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @people = Person.none
  end

  #GET
  def find
    @people = Queries::Person::Filter.new(params)
    render json: @people
  end

end
