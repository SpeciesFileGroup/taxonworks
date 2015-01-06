class ControlledVocabularyTermsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_controlled_vocabulary_term, only: [:show, :edit, :update, :destroy]

  # GET /controlled_vocabulary_terms
  # GET /controlled_vocabulary_terms.json
  def index
    @recent_objects = ControlledVocabularyTerm.recent_from_project_id($project_id).order(updated_at: :desc).limit(10)
  end

  # GET /controlled_vocabulary_terms/1
  # GET /controlled_vocabulary_terms/1.json
  def show
  end

  # GET /controlled_vocabulary_terms/new
  def new
    @controlled_vocabulary_term = ControlledVocabularyTerm.new
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
        redirect_url = (request.env['HTTP_REFERER'].include?('controlled_vocabulary_terms/new') ? controlled_vocabulary_term_path(@controlled_vocabulary_term) : :back)
        format.html { redirect_to redirect_url, notice: 'Controlled vocabulary term was successfully created.' } # !! new behaviour to test
        format.json { render action: 'show', status: :created, location: @controlled_vocabulary_term.metamorphosize}
      else
        format.html { 
          flash[:notice] = 'Controlled vocabulary term NOT successfully created.' 
          if redirect_url == :back 
            redirect_to :back 
          else
            render action: 'new'
          end
        }
        format.json { render json: @controlled_vocabulary_term.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /controlled_vocabulary_terms/1
  # PATCH/PUT /controlled_vocabulary_terms/1.json
  def update
    respond_to do |format|
      if @controlled_vocabulary_term.update(controlled_vocabulary_term_params)
        format.html { redirect_to @controlled_vocabulary_term.metamorphosize, notice: 'Controlled vocabulary term was successfully updated.' }
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
    if params[:id]
      redirect_to controlled_vocabulary_term_path(params[:id])
    else
      redirect_to controlled_vocabulary_term_path, notice: 'You must select an item from the list with a click or tab press before clicking show.'
    end
  end

  def list
    @controlled_vocabulary_terms =  ControlledVocabularyTerm.with_project_id($project_id).order(:id).page(params[:page]) #.per(10) #.per(3)
  end

  def autocomplete
    @controlled_vocabulary_terms = ControlledVocabularyTerm.find_for_autocomplete(params.merge(project_id: sessions_current_project_id))

    data = @controlled_vocabulary_terms.collect do |t|
      {id:              t.id,
       label:           ControlledVocabularyTermsHelper.controlled_vocabulary_term_tag(t),
       response_values: {
         params[:method] => t.id
       },
       label_html:      ControlledVocabularyTermsHelper.controlled_vocabulary_term_tag(t) #  render_to_string(:partial => 'shared/autocomplete/taxon_name.html', :object => t)
      }
    end

    render :json => data
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_controlled_vocabulary_term
      @controlled_vocabulary_term = ControlledVocabularyTerm.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def controlled_vocabulary_term_params
      params.require(:controlled_vocabulary_term).permit(:type, :name, :definition, :uri, :uri_relation)
    end
end
