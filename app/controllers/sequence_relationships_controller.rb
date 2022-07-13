class SequenceRelationshipsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_sequence_relationship, only: [:show, :edit, :update, :destroy]

  # GET /sequence_relationships
  # GET /sequence_relationships.json
  def index
    @recent_objects = SequenceRelationship.recent_from_project_id(sessions_current_project_id)
      .order(updated_at: :desc).limit(10)
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
        format.html { redirect_to sequence_relationship_path(@sequence_relationship),
                                  notice: 'Sequence relationship was successfully created.' }
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
        format.html { redirect_to url_for(@sequence_relationship.metamorphosize),
                                  notice: 'Sequence relationship was successfully updated.' }
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
      if @sequence_relationship.destroyed?
        format.html { destroy_redirect @sequence_relationship, notice: 'Sequence relationship was successfully destroyed.' }
        format.json { head :no_content}
      else
        format.html { destroy_redirect @sequence_relationship, notice: 'Sequence relationship was not destroyed, ' + @sequence_relationship.errors.full_messages.join('; ') }
        format.json { render json: @sequence_relationship.errors, status: :unprocessable_entity }
      end
    end
  end


  def search
    if params[:id].blank?
      redirect_to sequence_relationships_path, notice: 'You must select an item from the list with a ' \
                                                            'click or tab press before clicking show.'
    else
      redirect_to sequence_relationship_path(params[:id])
    end
  end

  def batch_load
  end

  def preview_primers_batch_load
    if params[:file]
      @result = BatchLoad::Import::SequenceRelationships::PrimersInterpreter.new(**batch_params)
      digest_cookie(params[:file].tempfile, :Primers_sequences_md5)
      render 'sequence_relationships/batch_load/primers/preview'
    else
      flash[:notice] = 'No file provided!'
      redirect_to action: :batch_load
    end
  end

  def create_primers_batch_load
    if params[:file] && digested_cookie_exists?(params[:file].tempfile, :Primers_sequences_md5)
      @result = BatchLoad::Import::SequenceRelationships::PrimersInterpreter.new(**batch_params)
      if @result.create!
        flash[:notice] = "Successfully proccessed file, #{@result.total_records_created} " \
                            'sequence relationships were created.'
        render 'sequence_relationships/batch_load/primers/create' and return
      else
        flash[:alert] = 'Batch import failed.'
      end
    else
      flash[:alert] = 'File to batch upload must be supplied.'
    end
    render :batch_load
  end

  private

  def set_sequence_relationship
    @sequence_relationship = SequenceRelationship.where(project_id: sessions_current_project_id).find(params[:id])
  end

  def sequence_relationship_params
    params.require(:sequence_relationship).permit(:subject_sequence_id, :type,
                                                  :object_sequence_id, :created_by_id, :updated_by_id, :project_id)
  end

  def batch_params
    params.permit(:name, :file, :import_level, files: [])
      .merge(user_id: sessions_current_user_id, project_id: sessions_current_project_id).to_h.symbolize_keys
  end
end
