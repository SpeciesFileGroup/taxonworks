class CollectionObjectsController < ApplicationController
  include DataControllerConfiguration

  before_action :require_sign_in_and_project_selection
  before_action :set_collection_object, only: [:show, :edit, :update, :destroy]

  # GET /collection_objects
  # GET /collection_objects.json
  def index
    @collection_objects = CollectionObject.all
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
