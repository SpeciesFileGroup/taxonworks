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
    scope = DwcOccurrence.otus_join
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
=begin
    1. find all geographic_items in area(s)/shape
    2. georeferences which are associated with result #1
    3. collecting_events which are associated with result #2
    4. collection_objects which are associated with result #3
    5. otus which are associated with result #4
=end
  def set_area
    render json: {html: otus.count.to_s}
  end

  # GET
  def set_date
    chart = render_to_string(
        partial: 'stats',
        locals: {count: otus.count,
                 objects: otus
        }
    )
    render json: {html: otus.count.to_s, chart: chart}
  end

  # GET
  def set_otu
    render json: {html: otus.count}
  end

  # GET
  def set_id_range
    render json: {html: otus.count}
  end

  # GET
  def set_user_date_range
    params[:user] = params[:user].to_i
    render json: {html: otus.count}
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
    render json: {first_date: Otu.in_project(sessions_current_project_id)
                                  .first_created.created_at.to_date.to_s.gsub('-', '/'),
                  last_date: Otu.in_project(sessions_current_project_id)
                                 .last_created.created_at.to_date.to_s.gsub('-', '/')
    }
  end

  def get_updated_at
    render json: {first_date: Otu.in_project(sessions_current_project_id)
                                  .first_updated.updated_at.to_date.to_s.gsub('-', '/'),
                  last_date: Otu.in_project(sessions_current_project_id)
                                 .last_updated.updated_at.to_date.to_s.gsub('-', '/')
    }
  end


  def otus
    scope = Queries::OtuFilterQuery.new(filter_params)
                .result
                .with_project_id(sessions_current_project_id)
                # .includes(:repository, {taxon_determinations: [{otu: :taxon_name}]}, :identifiers)
    scope
  end

  def filter_params
    params.permit(:drawn_area_shape, :search_start_date, :search_end_date,
                  :id_range_start, :id_range_stop, :id_namespace,
                  :user, :date_type_select, :user_date_range_end, :user_date_range_start,
                  :partial_overlap, :otu_id, :descendants, :page, geographic_area_ids: [])
  end

end
