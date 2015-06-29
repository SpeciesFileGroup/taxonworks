class Tasks::Gis::OtuDistributionDataController < ApplicationController
  def show
    @otu = Otu.second
  end
end
