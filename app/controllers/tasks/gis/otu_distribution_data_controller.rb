class Tasks::Gis::OtuDistributionDataController < ApplicationController
  def show
    id = params[:id]
    if id.blank?
      @otu = Otu.first
    else
      @otu = Otu.find(id)
    end
  end

  def show2
    id = params[:id]
    if id.blank?
      @otu = Otu.first
    else
      @otu = Otu.find(id)
    end
    @distribution = Distribution.new(otus: [@otu])
  end
end
