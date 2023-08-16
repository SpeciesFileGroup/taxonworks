class OtuRelationshipsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_otu_relationship, only: %i[ show edit update destroy ]

  after_action -> { set_pagination_headers(:otu_relationships) }, only: [:index], if: :json_request?

  # GET /otu_relationships or /otu_relationships.json
  def index
    respond_to do |format|
      format.html do
        @recent_objects = OtuRelationship.where(project_id: sessions_current_project_id)
        .order(updated_at: :desc)
        .limit(10)
        render '/shared/data/all/index'
      end
      format.json {
        @otu_relationships = OtuRelationship.where(project_id: sessions_current_project_id)
          .page(params[:page])
          .per(params[:per])
      }
    end
  end

  # GET /otu_relationships/1 or /otu_relationships/1.json
  def show
  end

  def list
    @otu_relationships = OtuRelationship.where(project_id: sessions_current_project_id)
      .page(params[:page])
      .per(params[:per])
  end

  # GET /otu_relationships/new
  def new
    @otu_relationship = OtuRelationship.new
  end

  # GET /otu_relationships/1/edit
  def edit
  end

  # POST /otu_relationships or /otu_relationships.json
  def create
    @otu_relationship = OtuRelationship.new(otu_relationship_params)

    respond_to do |format|
      if @otu_relationship.save
        format.html { redirect_to otu_relationship_url(@otu_relationship), notice: 'Otu relationship was successfully created.' }
        format.json { render :show, status: :created, location: @otu_relationship.metamorphosize }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @otu_relationship.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /otu_relationships/1 or /otu_relationships/1.json
  def update
    respond_to do |format|
      if @otu_relationship.update(otu_relationship_params)
        format.html { redirect_to otu_relationship_url(@otu_relationship), notice: 'Otu relationship was successfully updated.' }
        format.json { render :show, status: :ok, location: @otu_relationship.metamorphosize }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @otu_relationship.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /otu_relationships/1 or /otu_relationships/1.json
  def destroy
    @otu_relationship.destroy

    respond_to do |format|
      format.html { redirect_to otu_relationships_url, notice: 'Otu relationship was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  def set_otu_relationship
    @otu_relationship = OtuRelationship.where(project_id: sessions_current_project_id).find(params[:id])
  end

  def otu_relationship_params
    params.require(:otu_relationship).permit(
      :subject_otu_id,
      :type,
      :object_otu_id
      )
  end
end
