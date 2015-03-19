class Tasks::Serials::SimilarController < ApplicationController
  include TaskControllerConfiguration

  #    match 'find_similar_serials_task', to: 'tasks/serial/find_similar', via: 'get'
  #POST & GET find_similar_serials_task_path
  def find
  end

  #GET  similar_serials? or Get serial/similar:id
  def like
    @serial = Serial.find(params[:id])
    @similar_serials = @serial.nearest_by_levenshtein(@serial.name[0..254])
    @related_routes = UserTasks.related_routes('similar_serials_task')

# this is where you do the computation of similar things.
# stick values in an @var, then page can access

# serials like me
  end
  #POST update_similar:id?
  # goal is to reload similar serial with new search parameter
  def update_find
     # want to get value of search box & ID
  end

  # def update
  # end
  #
  # def within
  # end
end
