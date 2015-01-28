class Tasks::Gis::AssertedDistributionController < ApplicationController
  def new
    # Otu.something
    @otu = Otu.find(params[:asserted_distribution][:otu_id])
    areas = GeographicArea.with_name_and_parent_name(['Champaign', 'Illinois'])
    @feature_collection = ::Gis::GeoJSON.feature_collection(areas)
  end

  def create

  end

  def generate_choices

  end

  def display_coordinates
    @asserted_distribution = AssertedDistribution.new
    @json_coors = params.to_json
    # @otu = Otu.find(params[:asserted_distribution][:otu_id])
    @otu = Otu.find(1)
    # @source = Source.find(params[:asserted_distribution][:source_id])
    @source = Source.find(1)
    @asserted_distributions = [AssertedDistribution.new(otu: @otu, source: @source, geographic_area_id: 236)]
    render partial: "/asserted_distributions/quick_form", collection: @asserted_distributions, as: :asserted_distribution

  end
end
