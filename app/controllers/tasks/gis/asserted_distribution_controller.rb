class Tasks::Gis::AssertedDistributionController < ApplicationController
  include TaskControllerConfiguration

  before_action :build_locks, only: [:new, :create, :generate_choices]

  # GET /new
  def new
    @asserted_distribution = AssertedDistribution.new(asserted_distribution_params)
    @asserted_distribution.origin_citation ||= Citation.new
  end

  # POST /asserted_distributions
  def create
    @asserted_distribution = AssertedDistribution.new(asserted_distribution_params)
    if @asserted_distribution.save
      flash[:notice]         = 'Asserted distribution was successfully created.'
      @asserted_distribution = AssertedDistribution.stub(defaults: locked_params(locks: @locks))
    else
      flash[:notice] = 'Failed to create asserted distribution.'
    end
    render :new
  end

  # GET /generate_choices
  def generate_choices
    geographic_areas = GeographicArea.find_by_lat_long( params.permit(:latitude)['latitude'].to_f,
                                                       params.permit(:longitude)['longitude'].to_f
                                            )

    feature_collection = ::Gis::GeoJSON.feature_collection(geographic_areas)

    asserted_distributions = AssertedDistribution.stub_new(
      otu_id:           otu_id_param,
      source_id:        source_id_param,
      geographic_areas: geographic_areas
    )

    render json: {
      html:  render_to_string(
        partial:'asserted_distributions/quick_new_asserted_distribution_form',
        collection: asserted_distributions,
        as:  :asserted_distribution,
      ),
      feature_collection: feature_collection
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

  # @return [Hash]
  #   the values of the locked params, nil if not locked
  def locked_params(locks: nil)
    {
      source_id: locks.resolve(:asserted_distribution, :source_id, source_id_param),
      otu_id: locks.resolve(:asserted_distribution, :otu_id, otu_id_param),
    }
  end

  # @return [Otu#id, nil]
  def otu_id_param
    begin
      params.require(:asserted_distribution).permit(:otu_id)[:otu_id]
    rescue ActionController::ParameterMissing
      return nil
    end
  end

  # @return [Source#id, nil]
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
                                                    origin_citation_attributes: [:source_id])
    rescue ActionController::ParameterMissing
      return ActionController::Parameters.new(AssertedDistribution.new.attributes).permit!
    end
  end

end
