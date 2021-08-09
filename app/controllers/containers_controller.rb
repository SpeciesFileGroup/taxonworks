class ContainersController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_container, only: [:update, :destroy, :show, :edit]

  # GET /containers
  # GET /containers.json
  def index
    @recent_objects = Container.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
  end

  # GET /containers/1
  # GET /containers/1.json
  def show
  end

  # GET /containers/for/global_id
  def for
    object = GlobalID::Locator.locate(params.require(:global_id))
    @container = object.respond_to?(:containable?) ? object.container : nil
    render(json: { 'message' => 'Record not found' }, status: :unauthorized) if !object.is_community? && object.project_id != sessions_current_project_id
    render(json: { success: false}, status: :not_found) and return if @container.nil?
    render :show
  end

  # GET /containers/new
  def new
    @container = Container.new
  end

  # GET /containers/1/edit
  def edit
  end

  def list
    @containers = Container.with_project_id(sessions_current_project_id).order(:id).page(params[:page]) #.per(10)
  end

  # POST /containers
  # POST /containers.json
  def create
    @container = Container.new(container_params)
    respond_to do |format|
      if @container.save
        format.html {redirect_back(fallback_location: (request.referer || root_path), notice: 'Container was successfully created.')}
        format.json { render :show, status: :created, location: @container.metamorphosize }
      else
        format.html {redirect_back(fallback_location: (request.referer || root_path), notice: 'Container was NOT successfully created.')}
        format.json { render json: @container.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /containers/1
  # PATCH/PUT /containers/1.json
  def update
    respond_to do |format|
      if @container.update(container_params)
        format.html {redirect_back(fallback_location: (request.referer || root_path), notice: 'Container was successfully updated.')}
        format.json { head :no_content }
      else
        format.html {redirect_back(fallback_location: (request.referer || root_path), notice: 'Container was NOT successfully updated.')}
        format.json { render json: @container.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /containers/1
  # DELETE /containers/1.json
  def destroy
    @container.destroy
    respond_to do |format|
      if @container.destroyed?
        format.html { destroy_redirect @container, notice: 'Container was successfully destroyed.' }
        format.json { head :no_content }
      else
        format.html { destroy_redirect @container, notice: 'Container was not destroyed, ' + @container.errors.full_messages.join('; ') }
        format.json { render json: @container.errors, status: :unprocessable_entity }
      end
    end
  end

  def search
    if params[:id].blank?
      redirect_to containers_path, alert: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to container_path(params[:id])
    end
  end

  def autocomplete
    @containers = Queries::Container::Autocomplete.new(
      params.require(:term), 
      {project_id: sessions_current_project_id}
    ).autocomplete
  end

  private
  def set_container
    @container = Container.with_project_id(sessions_current_project_id).find(params[:id])
  end

  def container_params
    params.require(:container).permit(:parent_id, :type, :name, :disposition, :size_x, :size_y, :size_z)
  end
end
