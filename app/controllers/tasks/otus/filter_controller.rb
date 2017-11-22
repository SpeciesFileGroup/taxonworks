class Tasks::Otus::FilterController < ApplicationController
  include TaskControllerConfiguration

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
      send_data(data.getzip, :type => 'application/zip', filename: data.filename)
    ensure
      data.cleanup
    end
  end

  # GET
  def set_area
    render json: {html: otus.count.to_s}
  end

  # GET
  def set_author
    render json: {html: otus.count}
  end

  # GET
  def set_nomen
    render json: {html: otus.count}
  end

  protected

  def otus
    scope = Queries::OtuFilterQuery.new(filter_params)
              .result
              .with_project_id(sessions_current_project_id)
    # .includes(:repository, {taxon_determinations: [{otu: :taxon_name}]}, :identifiers)
    scope
  end

  def filter_params
    params.permit(:drawn_area_shape, :nomen_id, :descendants, :page, author_ids: [], geographic_area_ids: [])
  end

end
