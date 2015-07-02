class Tasks::Gis::OtuDistributionDataController < ApplicationController
  def show
    id = params[:id]
    if id.blank?
      @otu = Otu.first
    else
      @otu = Otu.find(id)
    end
  end
end
