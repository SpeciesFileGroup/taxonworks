class Tasks::CollectionObjects::FilterController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @collection_objects = CollectionObject.none
  end

  # POST
  def find
    @collection_objects = collection_objects.page(params[:page])
  end

  # GET
  def set_area
    render json: {html: collection_objects.count.to_s}
  end

  # GET
  def set_date
    chart  = render_to_string(
      partial: 'stats',
      locals:  {
        count: collection_objects.count,
        objects: collection_objects
      }
    )
    render json: {html: collection_objects.count.to_s, chart: chart}
  end

  # GET
  def set_otu
    render json: {html: collection_objects.count}
  end

  protected

  def collection_objects
    Queries::CollectionObjectFilterQuery.new(filter_params)
      .result
      .with_project_id(sessions_current_project_id)
      .order('collection_objects.id')
      .includes(:repository, {taxon_determinations: [{otu: :taxon_name}]}, :identifiers)
  end

  def filter_params
    params.permit(:geographic_area_id, :drawn_area_shape, :search_start_date, :search_end_date, :partial_overlap, :otu_id, :descendants, :page)
  end

end
