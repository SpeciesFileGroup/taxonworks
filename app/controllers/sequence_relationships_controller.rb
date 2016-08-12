class SequenceRelationshipsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_sequence_relationship, only: [:show, :edit, :update, :destroy]

  # GET /sequence_relationships
  # GET /sequence_relationships.json
  def index
    @recent_objects = SequenceRelationship.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
  end

  # GET /sequence_relationships/1
  # GET /sequence_relationships/1.json
  def show
  end

  # GET /sequence_relationships/new
  def new
    @sequence_relationship = SequenceRelationship.new
  end

  # GET /sequence_relationships/1/edit
  def edit
  end

  def list
    @sequence_relationships = SequenceRelationship.with_project_id(sessions_current_project_id).page(params[:page])
  end

  # POST /sequence_relationships
  # POST /sequence_relationships.json
  def create
    @sequence_relationship = SequenceRelationship.new(sequence_relationship_params)

    respond_to do |format|
      if @sequence_relationship.save
        format.html { redirect_to @sequence_relationship, notice: 'Sequence relationship was successfully created.' }
        format.json { render :show, status: :created, location: @sequence_relationship }
      else
        format.html { render :new }
        format.json { render json: @sequence_relationship.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sequence_relationships/1
  # PATCH/PUT /sequence_relationships/1.json
  def update
    respond_to do |format|
      if @sequence_relationship.update(sequence_relationship_params)
        format.html { redirect_to @sequence_relationship, notice: 'Sequence relationship was successfully updated.' }
        format.json { render :show, status: :ok, location: @sequence_relationship }
      else
        format.html { render :edit }
        format.json { render json: @sequence_relationship.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sequence_relationships/1
  # DELETE /sequence_relationships/1.json
  def destroy
    @sequence_relationship.destroy
    respond_to do |format|
      format.html { redirect_to sequence_relationships_url, notice: 'Sequence relationship was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sequence_relationship
      @sequence_relationship = SequenceRelationship.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sequence_relationship_params
      params.require(:sequence_relationship).permit(:subject_sequence, :relationship_type, :object_sequence, :created_by_id, :updated_by_id, :project_id)
    end
end
