class DataAttributesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_data_attribute, only: [:update, :destroy]

  # GET /data_attributes
  # GET /data_attributes.json
  def index
    respond_to do |format|
      format.html {
        @recent_objects = DataAttribute.where(project_id: sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      }
      format.json {
        @data_attributes = DataAttribute.where(project_id: sessions_current_project_id).where(
          polymorphic_filter_params( 'attribute_subject', DataAttribute.related_foreign_keys )
        )
      }
    end
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
        format.html { redirect_to @data_attribute.attribute_subject.metamorphosize, notice: 'Data attribute was successfully created.' }
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
        format.html { redirect_to @data_attribute.attribute_subject.metamorphosize, notice: 'Data attribute was successfully updated.' }
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
      format.html {redirect_back(fallback_location: (request.referer || root_path), notice: 'Data attribute was successfully destroyed.')}
      format.json { head :no_content }
    end
  end

  def list
    @data_attributes = DataAttribute.where(project_id: sessions_current_project_id).order(:attribute_subject_type).page(params[:page])
  end

  # GET /data_attributes/search
  def search
    if params[:id].blank?
      redirect_to data_attribute_path, notice: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to data_attribute_path(params[:id])
    end
  end

  def autocomplete
    @data_attributes = DataAttribute.find_for_autocomplete(params.merge(project_id: sessions_current_project_id)).limit(20)

    data = @data_attributes.collect do |t|
      str = render_to_string(partial: 'tag', locals: {data_attribute: t})
      {id: t.id,
       label: str,
       response_values: {
           params[:method] => t.id},
       label_html: str
      }
    end

    render json: data
  end

  # GET /data_attributes/download
  def download
    send_data Download.generate_csv(DataAttribute.where(project_id: sessions_current_project_id)), type: 'text', filename: "data_attributes_#{DateTime.now.to_s}.csv"
  end

  private
  
  def set_data_attribute
    @data_attribute = DataAttribute.find(params[:id])
    if !@data_attribute.project_id.blank? && (sessions_current_project_id != @data_attribute.project_id)
      render status: 404 and return
    end
  end

  def data_attribute_params
    params.require(:data_attribute).permit(
      :type,
      :attribute_subject_id,
      :attribute_subject_type,
      :controlled_vocabulary_term_id,
      :import_predicate,
      :value,
      :annotated_global_entity 
    )
  end
end
