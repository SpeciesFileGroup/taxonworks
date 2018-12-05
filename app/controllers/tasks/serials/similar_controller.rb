class Tasks::Serials::SimilarController < ApplicationController
  include TaskControllerConfiguration

  # GET tasks/serials/like/:id
  def like
    @serial = Serial.find(params[:id])
  end

end
