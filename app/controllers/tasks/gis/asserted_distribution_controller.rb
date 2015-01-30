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
    @asserted_distribution = AssertedDistribution.new
    @json_coors = params.to_json
    
    click_point = GeographicItem.new(point: Georeference::FACTORY.point(params['longitude'], params['latitude']))
    click_items = GeographicItem.is_contained_in('any_poly', click_point)
    click_areas = click_items.map(&:geographic_areas).flatten
   
    @click_area_names = click_areas.map(&:name)
    @feature_collection = ::Gis::GeoJSON.feature_collection(click_areas)
    @asserted_distributions = AssertedDistribution.stub_new(  params.require(:asserted_distribution).permit(:source_id, :otu_id).to_h.merge(params.permit(:latitude, :longitude)))
 
    render partial: 'asserted_distributions/quick_new_asserted_distribution_form', 
      collection: @asserted_distributions, 
      as: :asserted_distribution, 
      locals: {token:  form_authenticity_token }
  end
end
