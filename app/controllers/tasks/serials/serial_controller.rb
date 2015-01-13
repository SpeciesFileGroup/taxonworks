class Tasks::Serials::SerialController < ApplicationController
  include TaskControllerConfiguration

  #    match 'find_similar_serials_task', to: 'tasks/serial/find_similar', via: 'get'
  #GET find_similar_serials_task_path
  def find_similar

  end
  #GET  similar_serials? or Get serial/similar:id
  def similar
    a=1
    # this is where you do the computation of similar things.
    # stick values in an @var, then page can access
  end

  #POST update_similar:id?
  # goal is to reload similar serial with new search parameter
  def update_similar
     # want to get value of search box & ID
  end

  # def update
  # end
  #
  # def within
  # end
end
