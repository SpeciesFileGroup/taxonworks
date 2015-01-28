class Tasks::Gis::AssertedDistributionController < ApplicationController
  before_action :disable_turbolinks, only: [:new]

  def new
    # Otu.something
    @otu = Otu.find(params[:asserted_distribution][:otu_id])
    @feature_collection = ::Gis::GeoJSON.feature_collection([])
    @source = Source.find(1)
  end

  def create

  end

  def generate_choices

  end

  def display_coordinates
    @asserted_distribution = AssertedDistribution.new
    @json_coors = params.to_json
    # @otu = Otu.find(params[:asserted_distribution][:otu_id])
    # @otu = Otu.find(@otu)
    # @source = Source.find(params[:asserted_distribution][:source_id])
    # @source = Source.find(1)
    click_point = GeographicItem.new(point: Georeference::FACTORY.point(params["lon"], params["lat"]))
    click_items = GeographicItem.is_contained_in('any_poly', click_point)
    # click_areas = click_items.geographic_areas.first
    click_areas = GeographicArea.with_name_and_parent_name(['Champaign', 'Illinois'])
    @feature_collection = ::Gis::GeoJSON.feature_collection(click_areas)
    @asserted_distributions = [AssertedDistribution.new(otu: @otu, source: @source )]
    render partial: "/asserted_distributions/quick_form", collection: @asserted_distributions, as: :asserted_distribution

  end
end
