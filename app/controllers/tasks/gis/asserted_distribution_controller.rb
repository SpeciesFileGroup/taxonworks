class Tasks::Gis::AssertedDistributionController < ApplicationController
  include TaskControllerConfiguration
 
  before_filter :build_locks, only: [:new, :create, :generate_choices]

  def new
    @asserted_distribution = AssertedDistribution.new(asserted_distribution_params)
    @asserted_distribution.origin_citation ||= Citation.new
    @feature_collection = ::Gis::GeoJSON.feature_collection([])
  end

  # POST /asserted_distributions
  # POST /asserted_distributions.json
  def create
    @asserted_distribution = AssertedDistribution.new(asserted_distribution_params)
    if @asserted_distribution.save
      flash[:notice] = 'Asserted distribution was successfully created.' 
      @locked_params = locked_params(locks: @locks)
      @asserted_distribution = stub( defaults: @locked_params) 
    else
      flash[:notice] = 'Failed to create asserted distribution.'
    end
    render :new
  end

  # TODO: move this to model!
  def stub(defaults: {})
    a = AssertedDistribution.new(
      otu_id: defaults[:otu_id], 
      origin_citation_attributes: {source_id: defaults[:source_id]}
    )
    a.origin_citation = Citation.new if defaults[:source_id].blank?
    a
  end

  def generate_choices
    geographic_areas = GeographicArea.find_by_lat_long( params['latitude'].to_f,
                                                       params['longitude'].to_f
                                                      )

    feature_collection     = ::Gis::GeoJSON.feature_collection(geographic_areas)
    asserted_distributions = AssertedDistribution.stub_new(
      otu_id: otu_id_param,       # collection_params[:otu_id],
      source_id: source_id_param, # collection_params[:origin_citation][:source_id],
      geographic_areas: geographic_areas
    )

    @token = form_authenticity_token

    render json: {
      html:               render_to_string(partial:    'asserted_distributions/quick_new_asserted_distribution_form',
                                           collection: asserted_distributions,
                                           as:         :asserted_distribution,
                                           locals:     {
                                             url:  create_asserted_distribution_task_path,
                                             token:       form_authenticity_token,
                                             locks: @locks
                                           }),
                                           feature_collection: feature_collection,

    }
  end

  protected

  def build_locks
    @locks = Forms::FieldLocks.new(lock_params || {})
  end

  # @return [Hash]
  #   the state of the locks, values are 1 for locked locks
  def lock_params
    params.permit(locks: {asserted_distribution: [:otu_id, :source_id]})[:locks] 
  end

  # @return [Id, nil]
  #   the values of the locked params, nil of not locked
  def locked_params(locks: nil)
    {
      source_id: locks.resolve(:asserted_distribution, :source_id, source_id_param),
      otu_id: locks.resolve(:asserted_distribution, :otu_id, otu_id_param),
    }
  end

  # @return [Id, nil]
  def otu_id_param
    begin
      params.require(:asserted_distribution).permit(:otu_id)[:otu_id]
    rescue ActionController::ParameterMissing
      return nil
    end
  end

  # @return [Id, nil]
  def source_id_param
    begin
      params.require(:asserted_distribution).require(:origin_citation_attributes).permit(:source_id)[:source_id]
    rescue ActionController::ParameterMissing
      return nil
    end
  end

  def asserted_distribution_params
    begin
      params.require(:asserted_distribution).permit(:otu_id, :geographic_area_id, :is_absent,
                                                    origin_citation_attributes: [ :source_id] ) 
    rescue ActionController::ParameterMissing
      return ActionController::Parameters.new(AssertedDistribution.new.attributes).permit!
    end
  end

  # def collection_params
#   params.require(:asserted_distribution).permit(:otu_id, origin_citation: [:source_id])
# end

end
