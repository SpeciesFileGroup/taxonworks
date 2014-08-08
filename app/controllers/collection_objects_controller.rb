class CollectionObjectsController < ApplicationController
  include DataControllerConfiguration

  before_action :set_collection_object, only: [:show, :edit, :update, :destroy]

  # GET /collection_objects
  # GET /collection_objects.json
  def index
    @recent_objects = CollectionObject.recent_from_project_id($project_id).order(updated_at: :desc).limit(5)
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
        format.html { redirect_to @collection_object.becomes(CollectionObject), notice: 'Collection object was successfully created.' }
        format.json { render action: 'show', status: :created, location: @collection_object.becomes(CollectionObject) }
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
        format.html { redirect_to @collection_object.becomes(CollectionObject), notice: 'Collection object was successfully updated.' }
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

  def list
    @collection_objects =  CollectionObject.with_project_id($project_id).order(:id).page(params[:page]) #.per(10) #.per(3)
  end

  def autocomplete
    @collection_objects = CollectionObject.find_for_autocomplete(params.merge(project_id: sessions_current_project_id)) # in model

    data = @collection_objects.collect do |t|
      {id:              t.id,
       label:           CollectionObjectsHelper.collection_object_tag(t), # in helper
       response_values: {
           params[:method] => t.id
       },
       label_html:      CollectionObjectsHelper.collection_object_tag(t) #  render_to_string(:partial => 'shared/autocomplete/taxon_name.html', :object => t)
      }
    end

    render :json => data
  end

  def list
    @collection_objectss = CollectionObject.with_project_id($project_id).order(:id).page(params[:page]) #.per(10) #.per(3)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_collection_object
      @collection_object = CollectionObject.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def collection_object_params
      params.require(:collection_object).permit(:total, :type, :preparation_type_id, :repository_id, :created_by_id, :updated_by_id, :project_id)
    end
end
