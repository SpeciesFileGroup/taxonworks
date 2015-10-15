class Tasks::Serials::SimilarController < ApplicationController
  include TaskControllerConfiguration

  # GET tasks/serials/like/:id
  def like

    @serial = Serial.find(params[:id])

    @similar_serials = @serial.nearest_by_levenshtein(@serial.name[0..254])
    @related_routes = UserTasks.related_routes('similar_serials_task')
  end
  

end
