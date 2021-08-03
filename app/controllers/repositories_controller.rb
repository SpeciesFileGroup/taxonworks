class RepositoriesController < ApplicationController
  include DataControllerConfiguration::SharedDataControllerConfiguration

  before_action :set_repository, only: [:show, :edit, :update, :destroy]

  # GET /repositories
  # GET /repositories.json
  def index
    @repositories = Repository.limit(20)
    @recent_objects = Repository.order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
  end

  # GET /repositories/1
  # GET /repositories/1.json
  def show
  end

  # GET /repositories/new
  def new
    @repository = Repository.new
  end

  # GET /repositories/1/edit
  def edit
  end

  # POST /repositories
  # POST /repositories.json
  def create
    @repository = Repository.new(repository_params)

    respond_to do |format|
      if @repository.save
        format.html { redirect_to @repository, notice: 'Repository was successfully created.' }
        format.json { render action: 'show', status: :created, location: @repository }
      else
        format.html { render action: 'new' }
        format.json { render json: @repository.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /repositories/1
  # PATCH/PUT /repositories/1.json
  def update
    respond_to do |format|
      if @repository.update(repository_params)
        format.html { redirect_to @repository, notice: 'Repository was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @repository.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /repositories/1
  # DELETE /repositories/1.json
  def destroy
    @repository.destroy
    respond_to do |format|
      format.html { redirect_to repositories_url }
      format.json { head :no_content }
    end
  end

  def list
    @repositories = Repository.order(:id).page(params[:page]) #.per(10) #.per(3)
  end

  def search
    if params[:id].blank?
      redirect_to repositories_path, alert: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to repository_path(params[:id])
    end
  end

  def autocomplete
    @repositories = Queries::Repository::Autocomplete.new(params[:term], autocomplete_params).autocomplete
  end

  # GET /repositories/download
  def download
    send_data Export::Download.generate_csv(Repository.all), type: 'text', filename: "repositories_#{DateTime.now}.csv"
  end

  # GET /repositories/select_options
  def select_options
    @repositories = Repository.select_optimized(sessions_current_user_id, sessions_current_project_id)
  end

  private

  def autocomplete_params
    params.permit(alternate_value_type: []).to_h.symbolize_keys
  end

  def set_repository
    @repository = Repository.find(params[:id])
    @recent_object = @repository
  end

  def repository_params
    params.require(:repository).permit(:name, :url, :acronym, :status, :institutional_LSID, :is_index_herbarioum_record)
  end
end
