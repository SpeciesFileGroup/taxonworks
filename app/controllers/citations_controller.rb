class CitationsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :require_sign_in_and_project_selection
  before_action :set_citation, only: [:update, :destroy]

  def new
    @citation = Citation.new(citation_params)
  end

  def edit
    @citation = Citation.find_by_id(params[:id]).metamorphosize
  end

  # GET /citations
  # GET /citations.json
  def index
    @recent_objects = Citation.recent_from_project_id($project_id).order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
  end

  # POST /citations
  # POST /citations.json
  def create
    @citation = Citation.new(citation_params)

    respond_to do |format|
      if @citation.save
        format.html { redirect_to @citation.citation_object.metamorphosize, notice: 'Citation was successfully created.' }
        format.json { render json: @citation, status: :created, location: @citation }
      else
        format.html { redirect_to :back, notice: 'Citation was NOT successfully created.' }
        format.json { render json: @citation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /citations/1
  # PATCH/PUT /citations/1.json
  def update
    respond_to do |format|
      if @citation.update(citation_params)
        format.html { redirect_to @citation.citation_object.metamorphosize, notice: 'Citation was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { redirect_to :back, notice: 'Citation was NOT successfully updated.' }
        format.json { render json: @citation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /citations/1
  # DELETE /citations/1.json
  def destroy
    @citation.destroy
    respond_to do |format|
      format.html { redirect_to :back, notice: 'Citation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def list
    @citations = Citation.with_project_id($project_id).order(:citation_object_type).page(params[:page]) #.per(10) #.per(3)
  end

  def search
    if params[:id]
      redirect_to citation_path(params[:id])
    else
      redirect_to citations_path, notice: 'You must select an item from the list with a click or tab press before clicking show.'
    end
  end


  def autocomplete
    @citations = Citation.find_for_autocomplete(params.merge(project_id: sessions_current_project_id))
    data = @citations.collect do |t|
      lbl = render_to_string(partial: 'tag', citation: t)
      {id: t.id,
       label: lbl,
       response_values: {
           params[:method] => t.id
       },
       label_html: lbl
      }
    end

    render :json => data
  end

  # GET /citations/download
  def download
    send_data Citation.generate_download( Citation.where(project_id: $project_id) ), type: 'text', filename: "citations_#{DateTime.now.to_s}.csv"
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_citation
    @citation = Citation.with_project_id($project_id).find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def citation_params
    params.require(:citation).permit(:citation_object_type, :citation_object_id, :source_id)
  end
end
