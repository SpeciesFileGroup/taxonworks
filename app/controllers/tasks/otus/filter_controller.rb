class Tasks::Otus::FilterController < ApplicationController
  include TaskControllerConfiguration

  # TODO: deprecate all methods returning Otus for GET `otus.json`

  # GET
  def index
    @otus = Otu.none
  end

  # POST
  def find
    @otus = otus.order('otus.id').page(params[:page])
  end

  def download
    scope = DwcOccurrence.collection_objects_join
              .where(dwc_occurrence_object_id: otus.pluck(:id)) # !! see if we can get rid of pluck, shouldn't need it, but maybe complex join is not collapsabele to collection object id
              .where(project_id: sessions_current_project_id)
              .order('dwc_occurrences.id')

    # If failing remove begin/ensure/end to report Raised errors
    begin
      data = Dwca::Packer::Data.new(scope)
      send_data(data.getzip, type: 'application/zip', filename: data.filename)
    ensure
      data.cleanup
    end
  end

  # GET
  def set_area
    render json: {html: otus.count}
  end

  # GET
  def set_author
    render json: {html: otus.count}
  end

  # GET
  def set_nomen
    render json: {html: otus.count}
  end

  # GET
  def set_verbatim
    render json: {html: otus.count}
  end

  protected

  def otus
    Queries::Otu::Filter.new(filter_params).result
        .with_project_id(sessions_current_project_id)
  end

  def filter_params
    params.permit(
      :drawn_area_shape, :taxon_name_id, :descendants,
      :and_or_select, :rank_class, :page,
      :verbatim_author_string, author_ids: [], geographic_area_ids: [], selection_objetcs: [])
  end

end
