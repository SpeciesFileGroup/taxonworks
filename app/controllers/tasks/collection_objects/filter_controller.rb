class Tasks::CollectionObjects::FilterController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @collection_objects = CollectionObject.none
  end

  # POST
  def find
    @collection_objects = collection_objects.order('collection_objects.id').page(params[:page])
  end

  def download
    scope = DwcOccurrence.collection_objects_join
              .where(dwc_occurrence_object_id: collection_objects.pluck(:id)) # !! see if we can get rid of pluck, shouldn't need it, but maybe complex join is not collapsabele to collection object id
              .where(project_id: sessions_current_project_id)
              .order('dwc_occurrences.id')

    # If failing remove begin/ensure/end to report Raised errors
    begin
      data = Dwca::Packer::Data.new(scope)
      send_data(data.getzip, :type => 'application/zip', filename: data.filename)
    ensure
      data.cleanup
    end
  end

  # GET
  def set_area
    render json: {html: collection_objects.count.to_s}
  end

  # GET
  def set_date
    chart = render_to_string(
      partial: 'stats',
      locals: {count: collection_objects.count,
               objects: collection_objects
      }
    )
    render json: {html: collection_objects.count.to_s, chart: chart}
  end

  # GET
  def set_otu
    render json: {html: collection_objects.count}
  end

  def get_id_range
    raise
  end

  def set_id_range
    raise
  end

  protected

  def collection_objects
    Queries::CollectionObjectFilterQuery.new(filter_params)
      .result
      .with_project_id(sessions_current_project_id)
      .includes(:repository, {taxon_determinations: [{otu: :taxon_name}]}, :identifiers)
  end

  def filter_params
    params.permit(:drawn_area_shape, :search_start_date, :search_end_date, :partial_overlap, :otu_id, :descendants, :page, geographic_area_ids: [])
  end

end
