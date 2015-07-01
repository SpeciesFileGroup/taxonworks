class Tasks::Gis::OtuDistributionDataController < ApplicationController
  def show
    @otu = Otu.find(params[:id])
  end
end
