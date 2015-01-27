class Tasks::Gis::AssertedDistributionController < ApplicationController
  def new
    # Otu.something
    @otu = Otu.find(params[:asserted_distribution][:otu_id])

  end

  def create

  end

  def generate_choices

  end
end
