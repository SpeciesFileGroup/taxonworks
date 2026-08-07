class OriginRelationshipsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_origin_relationship, only: [:show, :edit, :update, :destroy]

  # GET /origin_relationships
  # GET /origin_relationships.json
  def index
    respond_to do |format|
      format.html{
        @recent_objects = OriginRelationship.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      }
      format.json{
        @origin_relationships = Queries::OriginRelationship::Filter.new(params)
          .all
          .page(params[:page])
          .per(params[:per])
      }
    end
  end

  # GET /origin_relationships/1
  # GET /origin_relationships/1.json
  def show
  end

  # GET /origin_relationships/new
  def new
    @origin_relationship = OriginRelationship.new
  end

  # GET /origin_relationships/1/edit
  def edit
  end

  def list
    @origin_relationships = OriginRelationship.with_project_id(sessions_current_project_id).page(params[:page])
  end

  # POST /origin_relationships
  # POST /origin_relationships.json
  def create
    @origin_relationship = OriginRelationship.new(origin_relationship_params)

    respond_to do |format|
      if @origin_relationship.save
        format.html { redirect_to @origin_relationship, notice: 'Origin relationship was successfully created.' }
        format.json { render :show, status: :created, location: @origin_relationship }
      else
        format.html { render :new }
        format.json { render json: @origin_relationship.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /origin_relationships/1
  # PATCH/PUT /origin_relationships/1.json
  def update
    respond_to do |format|
      if @origin_relationship.update(origin_relationship_params)
        format.html { redirect_to @origin_relationship, notice: 'Origin relationship was successfully updated.' }
        format.json { render :show, status: :ok, location: @origin_relationship }
      else
        format.html { render :edit }
        format.json { render json: @origin_relationship.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /origin_relationships/1
  # DELETE /origin_relationships/1.json
  def destroy
    @origin_relationship.destroy

    respond_to do |format|
      if @origin_relationship.destroyed?
        format.html { redirect_to origin_relationships_url, notice: 'Origin relationship was successfully destroyed.' }
        format.json { head :no_content }
      else
        format.html { destroy_redirect @origin_relationship, notice: 'Origin relationship was not destroyed, ' + @origin_relationship.errors.full_messages.join('; ') }
        format.json { render json: @origin_relationship.errors, status: :unprocessable_content }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_origin_relationship
    @origin_relationship = OriginRelationship.where(project_id: sessions_current_project_id).find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def origin_relationship_params
    params.require(:origin_relationship).permit(:old_object_id, :old_object_type, :new_object_id, :new_object_type, :position, :created_by_id, :updated_by_id, :project_id)
  end
end
