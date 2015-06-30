class Tasks::Gis::OtuDistributionDataController < ApplicationController
  def show
    @otu = Otu.first
  end
end
