class OriginRelationshipsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration
  include ShallowPolymorphic

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
        @origin_relationships = Queries::OriginRelationship::Filter.new(filter_params)
          .all
          .where(project_id: sessions_current_project_id)
          .page(params[:page])
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
        format.json { render json: @origin_relationship.errors, status: :unprocessable_entity }
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
        format.json { render json: @origin_relationship.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /origin_relationships/1
  # DELETE /origin_relationships/1.json
  def destroy
    @origin_relationship.destroy
    respond_to do |format|
      format.html { redirect_to origin_relationships_url, notice: 'Origin relationship was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def search
    if params[:id].blank?
      redirect_to origin_relationships_path, alert: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to origin_relationship_path(params[:id])
    end
  end

  # TODO: remove
  def autocomplete
    @origin_relationships = origin_relationship.where(project_id: sessions_current_project_id).where('origin_relationship ILIKE ?', "#{params[:term]}%")

    data = @origin_relationships.collect do |t|
      {id:              t.id,
       label:           t.origin_relationship,
       gid:             t.to_global_id.to_s,
       response_values: {
         params[:method] => t.id
       },
       label_html:      t.origin_relationship
      }
    end

    render json: data
  end

  private

  def filter_params
    params.permit(
      :new_object_global_id,
      :old_object_global_id,
    ).to_h
      .merge(
        old_object_global_id: shallow_object_global_param[:object_global_id],
        project_id: sessions_current_project_id
      )
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_origin_relationship
    @origin_relationship = OriginRelationship.where(project_id: sessions_current_project_id).find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def origin_relationship_params
    params.require(:origin_relationship).permit(:old_object_id, :old_object_type, :new_object_id, :new_object_type, :position, :created_by_id, :updated_by_id, :project_id)
  end
end
