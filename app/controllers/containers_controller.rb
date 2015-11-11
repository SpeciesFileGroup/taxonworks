class ContainersController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_container, only: [:update, :destroy, :show, :edit]

  # GET /containers
  # GET /containers.json
  def index
    @recent_objects = Container.recent_from_project_id($project_id).order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
  end

  # GET /containers/1
  # GET /containers/1.json
  def show
  end

  # GET /containers/new
  def new
    @container = Container.new
  end

  # GET /containers/1/edit
  def edit
  end

  def list
    @containers = Container.with_project_id($project_id).order(:id).page(params[:page]) #.per(10)
  end

  # POST /containers
  # POST /containers.json
  def create
    @container = Container.new(container_params)

    respond_to do |format|
      if @container.save
        format.html { redirect_to :back, notice: 'Container was successfully created.' }
        format.json { render json: @container, status: :created, location: @container }
      else
        format.html { redirect_to :back, notice: 'Container was NOT successfully created.' }
        format.json { render json: @container.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /containers/1
  # PATCH/PUT /containers/1.json
  def update
    respond_to do |format|
      if @container.update(container_params)
        format.html { redirect_to :back, notice: 'Container was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { redirect_to :back, notice: 'Container was NOT successfully updated.' }
        format.json { render json: @container.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /containers/1
  # DELETE /containers/1.json
  def destroy
    @container.destroy
    respond_to do |format|
      format.html { redirect_to :back, notice: 'Container was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def search
    if params[:id].blank?
      redirect_to containers_path, notice: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to container_path(params[:id])
    end
  end

  def autocomplete
    @containers = Container.find_for_autocomplete(params.merge(project_id: sessions_current_project_id)).includes(:taxon_name)
    data = @containers.collect do |t|
      {id: t.id,
       label: ApplicationController.helpers.container_tag(t),
       response_values: {
           params[:method] => t.id
       },
       label_html: ApplicationController.helpers.container_autocomplete_selected_tag(t)
      }
    end

    render :json => data
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_container
      @container = Container.with_project_id($project_id).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def container_params
      params.require(:container).permit(:parent_id, :depth, :type, :name, :disposition)
    end
end
