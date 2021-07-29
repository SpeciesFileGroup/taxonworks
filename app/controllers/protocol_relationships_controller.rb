class ProtocolRelationshipsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_protocol_relationship, only: [:show, :edit, :update, :destroy]

  # GET /protocol_relationships
  # GET /protocol_relationships.json
  def index
    respond_to do |format|
      format.html {
        @recent_objects = ProtocolRelationship.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      }

      format.json {
        @protocol_relationships = ProtocolRelationship.where(project_id: sessions_current_project_id).where(
          Queries::Annotator::polymorphic_params(params, ProtocolRelationship)
        )
      }
    end
  end

  # GET /protocol_relationships/1
  # GET /protocol_relationships/1.json
  def show
  end

  # GET /protocol_relationships/new
  def new
    @protocol_relationship = ProtocolRelationship.new

    if !Protocol.with_project_id(sessions_current_project_id).any? 
      redirect_to new_protocol_path, notice: 'Create a protocol or two first.' and return
    end
    @protocol_relationship= ProtocolRelationship.new(protocol_relationship_params)

  end

  # GET /protocol_relationships/1/edit
  def edit
  end

  def list
    @protocol_relationships = ProtocolRelationship.with_project_id(sessions_current_project_id).page(params[:page])
  end

  # POST /protocol_relationships
  # POST /protocol_relationships.json
  def create
    @protocol_relationship = ProtocolRelationship.new(protocol_relationship_params)

    respond_to do |format|
      if @protocol_relationship.save
        format.html { redirect_to @protocol_relationship, notice: 'Protocol relationship was successfully created.' }
        format.json { render :show, status: :created, location: @protocol_relationship }
      else
        format.html { render :new }
        format.json { render json: @protocol_relationship.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /protocol_relationships/1
  # PATCH/PUT /protocol_relationships/1.json
  def update
    respond_to do |format|
      if @protocol_relationship.update(protocol_relationship_params)
        format.html { redirect_to @protocol_relationship, notice: 'Protocol relationship was successfully updated.' }
        format.json { render :show, status: :ok, location: @protocol_relationship }
      else
        format.html { render :edit }
        format.json { render json: @protocol_relationship.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /protocol_relationships/1
  # DELETE /protocol_relationships/1.json
  def destroy
    @protocol_relationship.destroy
    respond_to do |format|
      format.html { redirect_to protocol_relationships_url, notice: 'Protocol relationship was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def search
    if params[:id].blank?
      redirect_to protocol_relationships_path, alert: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to protocol_relationship_path(params[:id])
    end
  end

  private
  
  def set_protocol_relationship
    @protocol_relationship = ProtocolRelationship.where(project_id: sessions_current_project_id).find(params[:id])
  end

  def protocol_relationship_params
    params.require(:protocol_relationship).permit(:protocol_id, :protocol_relationship_object_id, :protocol_relationship_object_type, :annotated_global_entity)
  end
end
