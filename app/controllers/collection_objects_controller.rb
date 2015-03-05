class CollectionObjectsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_collection_object, only: [:show, :edit, :update, :destroy]

  # GET /collection_objects
  # GET /collection_objects.json
  def index
    @recent_objects = CollectionObject.recent_from_project_id($project_id).order(updated_at: :desc).limit(10)
  end

  # GET /collection_objects/1
  # GET /collection_objects/1.json
  def show
  end

  # GET /collection_objects/new
  def new
    @collection_object = CollectionObject.new
  end

  # GET /collection_objects/1/edit
  def edit
  end

  # POST /collection_objects
  # POST /collection_objects.json
  def create
    @collection_object = CollectionObject.new(collection_object_params)

    respond_to do |format|
      if @collection_object.save
        format.html { redirect_to @collection_object.metamorphosize, notice: 'Collection object was successfully created.' }
        format.json { render action: 'show', status: :created, location: @collection_object.metamorphosize }
      else
        format.html { render action: 'new' }
        format.json { render json: @collection_object.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /collection_objects/1
  # PATCH/PUT /collection_objects/1.json
  def update
    respond_to do |format|
      if @collection_object.update(collection_object_params)
        @collection_object = @collection_object.metamorphosize
        format.html { redirect_to @collection_object, notice: 'Collection object was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @collection_object.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /collection_objects/1
  # DELETE /collection_objects/1.json
  def destroy
    @collection_object.destroy
    respond_to do |format|
      format.html { redirect_to collection_objects_url }
      format.json { head :no_content }
    end
  end

  # GET /collection_objects/list
  def list
    @collection_objects =  CollectionObject.with_project_id($project_id).order(:id).page(params[:page]) #.per(10) #.per(3)
  end

  # GET /collection_object/search
  def search
    if params[:id]
      redirect_to collection_object_path(params[:id])
    else
      redirect_to collection_object_path, notice: 'You must select an item from the list with a click or tab press before clicking show.'
    end
  end

  def autocomplete
    @collection_objects = CollectionObject.find_for_autocomplete(params.merge(project_id: sessions_current_project_id)) # in model
    data = @collection_objects.collect do |t|
      {id:              t.id,
       label:           CollectionObjectsHelper.collection_object_tag(t), # in helper
       response_values: {
         params[:method] => t.id
       },
       label_html:      CollectionObjectsHelper.collection_object_tag(t)  # render_to_string(:partial => 'shared/autocomplete/taxon_name.html', :object => t)
      }
    end
    render :json => data
  end

  # GET /collection_objects/download
  def download
    send_data CollectionObject.generate_download( CollectionObject.where(project_id: $project_id) ), type: 'text', filename: "collection_objects_#{DateTime.now.to_s}.csv"
  end

  private

  def set_collection_object
    @collection_object = CollectionObject.find(params[:id])
  end

  def collection_object_params
    params.require(:collection_object).permit(:total, :preparation_type_id, :repository_id, :ranged_lot_category_id, :collecting_event_id, :buffered_collecting_event, :buffered_deteriminations, :buffered_other_labels, :deaccessioned_at, :accession_provider, :deaccesion_recipient, :deaccession_reason)
  end
end
