class BiologicalRelationshipsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_biological_relationship, only: [:show, :edit, :update, :destroy]

  # GET /biological_relationships
  # GET /biological_relationships.json
  def index
    respond_to do |format|
      format.html do
        @recent_objects = BiologicalRelationship.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      end
      format.json {
        @biological_relationships = BiologicalRelationship.with_project_id(sessions_current_project_id).order(:name)
      }
    end
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
    @biological_relationships = BiologicalRelationship.with_project_id(sessions_current_project_id).order(:id).page(params[:page]) #.per(10)
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
    @biological_relationships = Queries::BiologicalRelationship::Autocomplete.new( params.require(:term), project_id: sessions_current_project_id).all
  end

  def select_options
    @biological_relationships = BiologicalRelationship.select_optimized(sessions_current_user_id, sessions_current_project_id)
  end

  private

  def filter_sql
    {}
  end

  def set_biological_relationship
    @biological_relationship = BiologicalRelationship.where(project_id: sessions_current_project_id).find(params[:id])
  end

  def biological_relationship_params
    params.require(:biological_relationship).permit(
      :name, :inverted_name, :is_transitive, :is_reflexive, :definition,
      biological_relationship_types_attributes: [:id, :_destroy, :type, :biological_property_id],
      origin_citation_attributes: [:id, :_destroy, :source_id, :pages]
    )
  end
end
