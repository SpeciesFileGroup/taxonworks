class ControlledVocabularyTermsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_controlled_vocabulary_term, only: [:show, :edit, :update, :destroy, :depictions, :citations, :confidences]

  # GET /controlled_vocabulary_terms
  # GET /controlled_vocabulary_terms.json
  def index
    respond_to do |format|
      format.html do
        @recent_objects = ControlledVocabularyTerm.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      end
      format.json {
        @controlled_vocabulary_terms = ControlledVocabularyTerm.where(filter_params).order(:name)
      }
    end
  end

  # GET /controlled_vocabulary_terms/1
  # GET /controlled_vocabulary_terms/1.json
  def show
  end

  # GET /controlled_vocabulary_terms/new
  def new
    redirect_to manage_controlled_vocabulary_terms_task_path and return
  end

  # GET /controlled_vocabulary_terms/1/edit
  def edit
    redirect_to manage_controlled_vocabulary_terms_task_path(controlled_vocabulary_term_id: @controlled_vocabulary_term.id) and return
  end

  # POST /controlled_vocabulary_terms.json
  def create
    @controlled_vocabulary_term = ControlledVocabularyTerm.new(controlled_vocabulary_term_params)
    respond_to do |format|
      if @controlled_vocabulary_term.save
        format.json {
          render action: 'show', status: :created, location: @controlled_vocabulary_term.metamorphosize
        }
      else
        format.json {
          render json: @controlled_vocabulary_term.errors, status: :unprocessable_entity
        }
      end
    end
  end

  # PATCH/PUT /controlled_vocabulary_terms/1.json
  def update
    respond_to do |format|
      if @controlled_vocabulary_term.update(controlled_vocabulary_term_params)
        format.json { render :show, status: :ok, location: @controlled_vocabulary_term.metamorphosize }
      else
        format.json { render json: @controlled_vocabulary_term.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /controlled_vocabulary_terms/1.json
  def destroy
    @controlled_vocabulary_term.destroy
    respond_to do |format|
      if @controlled_vocabulary_term.destroyed?
        format.html { destroy_redirect @controlled_vocabulary_term, notice: 'OTU was successfully destroyed.' }
        format.json { head :no_content}
      else
        format.html { destroy_redirect @controlled_vocabulary_term, notice: 'OTU was not destroyed, ' + @controlled_vocabulary_term.errors.full_messages.join('; ') }
        format.json { render json: @controlled_vocabulary_term.errors, status: :unprocessable_entity }
      end
    end
  end

  def search
    if params[:id].blank?
      redirect_to controlled_vocabulary_term_path, alert: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to controlled_vocabulary_term_path(params[:id])
    end
  end

  def list
    @controlled_vocabulary_terms = ControlledVocabularyTerm.with_project_id(sessions_current_project_id).order(:id).page(params[:page]) #.per(10) #.per(3)
  end

  def depictions
    render json: @controlled_vocabulary_terms.depictions
  end

  def citations
    render json: @controlled_vocabulary_terms.citations
  end

  def confidences
    render json: @controlled_vocabulary_terms.confidences
  end

  def autocomplete
    @controlled_vocabulary_terms = Queries::ControlledVocabularyTerm::Autocomplete.new(
      params.require(:term),
      controlled_vocabulary_term_type: filter_params[:type],
      project_id: sessions_current_project_id
    ).all
  end

  # GET /controlled_vocabulary_terms/download
  def download
    send_data(
      Export::Download.generate_csv(ControlledVocabularyTerm.where(project_id: sessions_current_project_id)),
      type: 'text',
      filename: "controlled_vocabulary_terms_#{DateTime.now}.csv")
  end

  # GET /controlled_vocabulary_terms/1/tagged_objects
  def tagged_objects
    set_controlled_vocabulary_term
  end

  private

  def set_controlled_vocabulary_term
    @controlled_vocabulary_term = ControlledVocabularyTerm.with_project_id(sessions_current_project_id).find(params[:id])
    @recent_object = @controlled_vocabulary_term
  end

  def controlled_vocabulary_term_params
    params.require(:controlled_vocabulary_term).permit(:type, :name, :definition, :uri, :uri_relation, :css_color)
  end

  def filter_params
    params.permit(
      type: [],
      id: []
    ).to_h.symbolize_keys.merge!(project_id: sessions_current_project_id)
  end

end
