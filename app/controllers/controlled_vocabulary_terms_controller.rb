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
    @controlled_vocabulary_term = ControlledVocabularyTerm.new
    @return_path = params.permit(:return_path)[:return_path]
  end

  # GET /controlled_vocabulary_terms/1/edit
  def edit
  end

  # POST /controlled_vocabulary_terms
  # POST /controlled_vocabulary_terms.json
  def create
    @controlled_vocabulary_term = ControlledVocabularyTerm.new(controlled_vocabulary_term_params)
    respond_to do |format|
      if @controlled_vocabulary_term.save
        format.html { redirect_to url_for(@controlled_vocabulary_term.metamorphosize), notice: "#{@controlled_vocabulary_term.type} '#{@controlled_vocabulary_term.name}' was successfully created." }
        format.json {
          render action: 'show', status: :created, location: @controlled_vocabulary_term.metamorphosize
        }
      else
        format.html {
          flash[:notice] = 'Controlled vocabulary term NOT successfully created.'
          render action: 'new'
        }
        format.json {
          render json: @controlled_vocabulary_term.errors, status: :unprocessable_entity
        }
      end
    end
  end

  # PATCH/PUT /controlled_vocabulary_terms/1
  # PATCH/PUT /controlled_vocabulary_terms/1.json
  def update
    respond_to do |format|
      if @controlled_vocabulary_term.update(controlled_vocabulary_term_params)
        format.html { redirect_to url_for(@controlled_vocabulary_term.metamorphosize), notice: 'Controlled vocabulary term was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @controlled_vocabulary_term.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /controlled_vocabulary_terms/1
  # DELETE /controlled_vocabulary_terms/1.json
  def destroy
    redirect_url = (request.env['HTTP_REFERER'].include?(controlled_vocabulary_term_path(@controlled_vocabulary_term.metamorphosize)) ? controlled_vocabulary_terms_url : :back)
    @controlled_vocabulary_term.destroy
    respond_to do |format|
      format.html { redirect_to redirect_url }
      format.json { head :no_content }
    end
  end

  def search
    if params[:id].blank?
      redirect_to controlled_vocabulary_term_path, notice: 'You must select an item from the list with a click or tab press before clicking show.'
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
      type: filter_params[:type],
      project_id: sessions_current_project_id
    ).all
  end

  # GET /controlled_vocabulary_terms/download
  def download
    send_data(Export::Download.generate_csv(ControlledVocabularyTerm.where(project_id: sessions_current_project_id)),
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
    params.permit(type: [], id: []).to_h.symbolize_keys.merge!(project_id: sessions_current_project_id)
  end

end
