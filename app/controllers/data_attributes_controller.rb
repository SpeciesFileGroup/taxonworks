class DataAttributesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_data_attribute, only: [:update, :destroy, :api_show]
  after_action -> { set_pagination_headers(:data_attributes) }, only: [:index, :api_index ], if: :json_request?

  # GET /data_attributes
  # GET /data_attributes.json
  def index
    respond_to do |format|
      format.html {
        @recent_objects = DataAttribute.where(project_id: sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      }
      format.json {
        @data_attributes = Queries::DataAttribute::Filter.new(params).all
          .page(params[:page])
          .per(params[:per])
      }
    end
  end

  def brief
    q = ::Queries::DataAttribute::Filter.new(params)

    render json: [], status: :unprocessable_entity and return if q.all.count > 30000

    @data = q.all.pluck('data_attributes.id, data_attributes.attribute_subject_id as object_id, data_attributes.controlled_vocabulary_term_id, data_attributes.value')
    cols = @data.collect{|a| a[1]}.uniq
    @columns = Predicate.where(project_id: sessions_current_project_id, id: cols).order(:name).pluck(:id, :name).inject([]){|ary, a| ary.push(a[0] => a[1]); ary}
  end

  # TODO: /brief differs in that the first value is id, determine whether we should do that in /api
  def api_brief
    q = ::Queries::DataAttribute::Filter.new(params)

    @data = q.all
      .page(params[:page])
      .per(params[:per])
      .pluck('data_attributes.attribute_subject_id as object_id, data_attributes.controlled_vocabulary_term_id, data_attributes.value')
    cols = @data.collect{|a| a[1]}.uniq
    @columns = Predicate.where(project_id: sessions_current_project_id, id: cols).order(:name).pluck(:id, :name).inject([]){|ary, a| ary.push(a[0] => a[1]); ary}

    render '/data_attributes/api/v1/brief'
  end

  def api_index
    @data_attributes = Queries::DataAttribute::Filter.new(params.merge!(api: true)).all
      .where(project_id: sessions_current_project_id)
      .page(params[:page])
      .per(params[:per])
    render '/data_attributes/api/v1/index'
  end

  def api_show
    render '/data_attributes/api/v1/show'
  end

  # GET /data_attributes/new
  def new
    @data_attribute = DataAttribute.new(data_attribute_params)
  end

  # GET /data_attributes/1/edit
  def edit
    @data_attribute = DataAttribute.find_by_id(params[:id])
  end

  # POST /data_attributes
  # POST /data_attributes.json
  def create
    @data_attribute = DataAttribute.new(data_attribute_params)
    respond_to do |format|
      if @data_attribute.save
        format.html { redirect_to url_for(@data_attribute.attribute_subject.metamorphosize), notice: 'Data attribute was successfully created.' }
        format.json { render action: 'show', status: :created, location: @data_attribute.metamorphosize }
      else

        format.html {redirect_back(fallback_location: (request.referer || root_path), notice: 'Data attribute was NOT successfully created.')}
        format.json { render json: @data_attribute.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /data_attributes/1
  # PATCH/PUT /data_attributes/1.json
  def update
    respond_to do |format|
      if @data_attribute.update(data_attribute_params)
        format.html { redirect_to url_for(@data_attribute.attribute_subject.metamorphosize), notice: 'Data attribute was successfully updated.' }
        format.json { render :show, status: :ok, location: @data_attribute.metamorphosize }
      else
        format.html { redirect_back(fallback_location: (request.referer || root_path), notice: 'Data attribute was NOT successfully updated.')}
        format.json { render json: @data_attribute.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /data_attributes/1
  # DELETE /data_attributes/1.json
  def destroy
    @data_attribute.destroy
    respond_to do |format|
      format.html { destroy_redirect @data_attribute, notice: 'Data attribute was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # /data_attributes/batch_create.json?attribute_subject_type=Otu&attribute_subject_id[]=123&value=456
  def batch_create
    @data_attributes = InternalAttribute.batch_create(batch_data_attribute_params)
    if @data_attributes.present?
      render '/data_attributes/index'
    else
      render json: { errors: ['Batch create failed - make sure your controlled vocabulary term is a predicate.'] }, status: :unprocessable_entity
    end
  end

  # /data_attributes/batch_update_or_create?<some_object>_query={}&value_from=123&value_to=456&predicate_id=890
  def batch_update_or_create
    if ::InternalAttribute.batch_update_or_create(params)
      render json: {}, status: :ok
    else
      render json: { errors: ['Batch update or create failed.'] }, status: :unprocessable_entity
    end
  end

  def list
    @data_attributes = DataAttribute.where(project_id: sessions_current_project_id).order(:attribute_subject_type).page(params[:page])
  end

  # GET /data_attributes/search
  def search
    if @data_attribute = DataAttribute.find(params[:id])
      redirect_to url_for(@data_attribute.attribute_subject.metamorphosize)
    else
      redirect_to data_attribute_path, alert: 'You must select an item from the list with a click or tab press before clicking show.'
    end
  end

  def autocomplete
    render json: {} and return if params[:term].blank?

    @data_attributes = Queries::DataAttribute::Autocomplete.new(
      params.require(:term),
      project_id: sessions_current_project_id
    ).autocomplete
  end

  def import_predicate_autocomplete

    render json: [] and return if params[:term].blank?

    @internal_attributes = ::DataAttribute
      .where(project_id: sessions_current_project_id)
      .where('import_predicate ilike ?', '%' + params[:term] + '%' )
      .order(:import_predicate)
      .distinct
      .limit(20)
      .pluck(:import_predicate)

    render json: @internal_attributes
  end

  def value_autocomplete
    render json: [] if params[:term].blank? || params[:predicate_id].blank?
    @values = ::Queries::DataAttribute::ValueAutocomplete.new(params[:term], **value_autocomplete_params).autocomplete
    render json: @values
  end

  # GET /data_attributes/download
  def download
    send_data Export::CSV.generate_csv(DataAttribute.where(project_id: sessions_current_project_id)), type: 'text', filename: "data_attributes_#{DateTime.now}.tsv"
  end

  private

  def value_autocomplete_params
    params.permit(:predicate_id).merge(project_id: sessions_current_project_id).to_h.symbolize_keys
  end

  def set_data_attribute
    @data_attribute = DataAttribute.find(params[:id])
    if @data_attribute.project_id.present? && (sessions_current_project_id != @data_attribute.project_id)
      render status: :not_found and return
    end
  end

  def base_params
    [ :type,
      :attribute_subject_id,
      :attribute_subject_type,
      :controlled_vocabulary_term_id,
      :import_predicate,
      :value,
      :annotated_global_entity
    ]
  end

  def batch_data_attribute_params
    p = base_params
    p << {attribute_subject_id: []}
    params.require(:data_attribute).permit(p)
  end

  def data_attribute_params
    params.require(:data_attribute).permit(base_params)
  end
end
