class Tasks::Serials::SimilarController < ApplicationController
  include TaskControllerConfiguration

  # GET tasks/serials/like/:id
  def like
    if params[:id]
      @serial = Serial.find(params[:id])
    else
      @serial = Serial.first
    end
  end

end
