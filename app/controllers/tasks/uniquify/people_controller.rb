class Tasks::Uniquify::PeopleController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @people = Person.none
  end

  # GET
  def find
    @people = Queries::Person::Filter.new(filter_params)
    render '/people/show' 
  end

  protected

  def filter_params
    params.permit(:roles, :last_name, :first_name)
  end

end
