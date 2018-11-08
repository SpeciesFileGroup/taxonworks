class BiologicalAssociationsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_biological_association, only: [:show, :edit, :update, :destroy]

  # GET /biological_associations
  # GET /biological_associations.json
  def index
    respond_to do |format|
      format.html {
        @recent_objects = BiologicalAssociation.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      }
      format.json {
        @biological_associations = Queries::BiologicalAssociation::Filter
          .new(filter_params)
          .all
          .where(project_id: sessions_current_project_id)
          .page(params[:page] || 1).per(500)
      }
    end
  end

  def filter_params
    params.permit(:subject_global_id, :object_global_id, :any_global_id, :biological_relationship_id)
  end
  
  # GET /biological_associations/1
  # GET /biological_associations/1.json
  def show
  end

  # GET /biological_associations/new
  def new
    @biological_association = BiologicalAssociation.new
  end

  # GET /biological_associations/1/edit
  def edit
  end

  def list
    @biological_associations = BiologicalAssociation.with_project_id(sessions_current_project_id).order(:id).page(params[:page]) #.per(10)
  end

  # POST /biological_associations
  # POST /biological_associations.json
  def create
    @biological_association = BiologicalAssociation.new(biological_association_params)

    respond_to do |format|
      if @biological_association.save
        format.html { redirect_to @biological_association, notice: 'Biological association was successfully created.' }
        format.json { render :show, status: :created, location: @biological_association }
      else
        format.html { render :new }
        format.json { render json: @biological_association.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /biological_associations/1
  # PATCH/PUT /biological_associations/1.json
  def update
    respond_to do |format|
      if @biological_association.update(biological_association_params)
        format.html { redirect_to @biological_association, notice: 'Biological association was successfully updated.' }
        format.json { render :show, status: :ok, location: @biological_association }
      else
        format.html { render :edit }
        format.json { render json: @biological_association.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /biological_associations/1
  # DELETE /biological_associations/1.json
  def destroy
    @biological_association.destroy
    respond_to do |format|
      format.html { redirect_to biological_associations_url, notice: 'Biological association was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def search
    if params[:id].blank?
      redirect_to biological_associations_path, notice: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to biological_association_path(params[:id])
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_biological_association
    @biological_association = BiologicalAssociation.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def biological_association_params
    params.require(:biological_association).permit(
      :biological_relationship_id, :biological_association_subject_id, :biological_association_subject_type, 
      :biological_association_object_id, :biological_association_object_type,
      :subject_global_id,
      :object_global_id,
      origin_citation_attributes: [:id, :_destroy, :source_id, :pages]
    )
  end
end
