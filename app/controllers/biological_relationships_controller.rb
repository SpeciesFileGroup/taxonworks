class BiologicalRelationshipsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_biological_relationship, only: [:show, :edit, :update, :destroy]

  # GET /biological_relationships
  # GET /biological_relationships.json
  def index
    @recent_objects = BiologicalRelationship.recent_from_project_id($project_id).order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
  end

  # GET /biological_relationships/1
  # GET /biological_relationships/1.json
  def show
  end

  # GET /biological_relationships/new
  def new
    @biological_relationship = BiologicalRelationship.new
  end

  # GET /biological_relationships/1/edit
  def edit
  end

  def list
    @biological_relationships = BiologicalRelationship.with_project_id($project_id).order(:id).page(params[:page]) #.per(10)
  end

  # POST /biological_relationships
  # POST /biological_relationships.json
  def create
    @biological_relationship = BiologicalRelationship.new(biological_relationship_params)

    respond_to do |format|
      if @biological_relationship.save
        format.html { redirect_to @biological_relationship, notice: 'Biological relationship was successfully created.' }
        format.json { render :show, status: :created, location: @biological_relationship }
      else
        format.html { render :new }
        format.json { render json: @biological_relationship.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /biological_relationships/1
  # PATCH/PUT /biological_relationships/1.json
  def update
    respond_to do |format|
      if @biological_relationship.update(biological_relationship_params)
        format.html { redirect_to @biological_relationship, notice: 'Biological relationship was successfully updated.' }
        format.json { render :show, status: :ok, location: @biological_relationship }
      else
        format.html { render :edit }
        format.json { render json: @biological_relationship.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /biological_relationships/1
  # DELETE /biological_relationships/1.json
  def destroy
    @biological_relationship.destroy
    respond_to do |format|
      format.html { redirect_to biological_relationships_url, notice: 'Biological relationship was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def search
    if params[:id].blank?
      redirect_to biological_relationships_path, notice: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to biological_relationship_path(params[:id])
    end
  end

  def autocomplete
    biological_relationships = BiologicalRelationship.find_for_autocomplete(params.merge(project_id: sessions_current_project_id))
    data = biological_relationships.collect do |t|
      {id: t.id,
       label: ApplicationController.helpers.biological_relationship_tag(t),
       response_values: {
           params[:method] => t.id
       },
       label_html: ApplicationController.helpers.biological_relationship_tag(t)
      }
    end

    render :json => data
  end

  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_biological_relationship
      @biological_relationship = BiologicalRelationship.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def biological_relationship_params
      params.require(:biological_relationship).permit(:name, :is_transitive, :is_reflexive, :created_by_id, :updated_by_id, :project_id)
    end
end
