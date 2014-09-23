class PapertrailController < ApplicationController

  # GET /hub
  def papertrail
    @object = params[:object_type].constantize.find(params[:object_id])
  end


end
