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
      send_data(data.getzip, type: 'application/zip', filename: data.filename)
    ensure
      data.cleanup
    end
  end

  # POST /tags/tag_all?keyword_id=123
  def tag_all
    if collection_objects.count < 2000
      if Tag.tag_objects( collection_objects, params.require(:keyword_id) )
        render json: { result: 'good' }
      else
        render json: { result: 'bad, error tagging objects' }
      end
    else
      render json: { result: 'Limited to tagging 2000 objects, refine result.' }
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
      locals:  {count:   collection_objects.count,
                objects: collection_objects
      }
    )
    render json: {html: collection_objects.count.to_s, chart: chart}
  end

  # GET
  def set_otu
    render json: {html: collection_objects.count}
  end

  # GET
  def set_id_range
    render json: {html: collection_objects.count}
  end

  # GET
  def set_user_date_range
    render json: {html: collection_objects.count}
  end

  # GET
  def get_dates_of_type
    case params[:date_type_select]
      when 'updated_at'
        get_updated_at
      when 'created_at'
        get_created_at
      # else
        #
    end
  end

  protected

  def get_created_at
    render json: {first_date: CollectionObject.in_project(sessions_current_project_id)
                                .first_created.created_at.to_date.to_s.gsub('-', '/'),
                  last_date:  CollectionObject.in_project(sessions_current_project_id)
                                .last_created.created_at.to_date.to_s.gsub('-', '/')
    }
  end

  def get_updated_at
    render json: {first_date: CollectionObject.in_project(sessions_current_project_id)
                                .first_updated.updated_at.to_date.to_s.gsub('-', '/'),
                  last_date:  CollectionObject.in_project(sessions_current_project_id)
                                .last_updated.updated_at.to_date.to_s.gsub('-', '/')
    }
  end


  def collection_objects
    scope = Queries::CollectionObject::Filter.new(filter_params)
              .result
              .with_project_id(sessions_current_project_id)
              .includes(:repository, {taxon_determinations: [{otu: :taxon_name}]}, :identifiers)
    scope
  end

  def filter_params
    params.permit(:drawn_area_shape, :search_start_date, :search_end_date,
                  :id_range_start, :id_range_stop, :id_namespace,
                  :user, :date_type_select, :user_date_range_end, :user_date_range_start,
                  :partial_overlap, :otu_id, :descendants, :page, geographic_area_ids: [])
  end

end
