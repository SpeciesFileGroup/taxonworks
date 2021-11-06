class DocumentationController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_documentation, only: [:show, :edit, :update, :destroy]

  # GET /documentation
  # GET /documentation.json
  def index
    respond_to do |format|
      format.html {
        @recent_objects = Documentation.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      }
      format.json {
        @documentation = ::Queries::Documentation::Filter.new(params).all.where(project_id: sessions_current_project_id).
        page(params[:page]).per(params[:per] || 500)
      }
    end
  end

  # GET /documentation/1
  # GET /documentation/1.json
  def show
  end

  # GET /documentation/new
  def new
    @documentation = Documentation.new
  end

  # GET /documentation/1/edit
  def edit
  end

  # POST /documentation
  # POST /documentation.json
  def create
    @documentation = Documentation.new(documentation_params)

    respond_to do |format|
      if @documentation.save
        format.html { redirect_to url_for(@documentation.metamorphosize),
                                  notice: 'Documentation was successfully created.' }
        format.json { render action: 'show', status: :created, location: @documentation }
      else
        format.html { render action: 'new' }
        format.json { render json: @documentation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /documentation/1
  # PATCH/PUT /documentation/1.json
  def update
    respond_to do |format|
      if @documentation.update(documentation_params)
        format.html { redirect_to url_for(@documentation.metamorphosize),
                                  notice: 'Documentation was successfully updated.' }
        format.json { render :show, status: :ok, location: @documentation }
      else
        format.html { render :edit }
        format.json { render json: @documentation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /documentation/1
  # DELETE /documentation/1.json
  def destroy
    @documentation.destroy
    respond_to do |format|
      format.html { redirect_to documentation_index_url, notice: 'Documentation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def list
    @documentation = Documentation.with_project_id(sessions_current_project_id).order(:id).page(params[:page]) #.per(10)
  end

  def search
    if params[:id].blank?
      redirect_to documentation_path, alert: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to documentation_path(params[:id])
    end
  end

  # inflection errors
  # GET /documentation/download
  # def download
  #   send_data Export::Download.generate_csv(
  #     Documentation.where(project_id: sessions_current_project_id)), type: 'text', filename: "documentation_#{DateTime.now}.csv"
  # end

  private

  def set_documentation
    @documentation = Documentation.where(project_id: sessions_current_project_id).find(params[:id])
  end

  def documentation_params
    params.require(:documentation).permit(
      :documentation_object_id, :documentation_object_type, :document_id, :annotated_global_entity, :position,
      document_attributes: [:document_file, :is_public]
    )
  end
end
