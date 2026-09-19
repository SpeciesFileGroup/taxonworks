class AssertedEnvironmentsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_asserted_environment, only: [:show, :edit, :update, :destroy]
  after_action -> { set_pagination_headers(:asserted_environments) }, only: [:index], if: :json_request?

  # GET /asserted_environments or /asserted_environments.json
  def index
    respond_to do |format|
      format.html {
        @recent_objects = AssertedEnvironment
          .where(project_id: sessions_current_project_id)
          .order(updated_at: :desc).limit(10)

        render '/shared/data/all/index'
      }
      format.json {
        @asserted_environments = ::Queries::AssertedEnvironment::Filter.new(params).all
          .where(project_id: sessions_current_project_id)
          .includes(:asserted_environment_object)
          .order(:cached, :id)
          .page(params[:page]).per(params[:per] || 500)
      }
    end
  end

  # GET /asserted_environments/1 or /asserted_environments/1.json
  def show
  end

  # GET /asserted_environments/list
  #   The Filter task (see the "asserted_environments/filter" task) covers
  #   faceted browsing and download - this is the plain sortable-table list
  #   every Data model gets.
  def list
    @asserted_environments = AssertedEnvironment
      .where(project_id: sessions_current_project_id)
      .order(:cached, :id)
      .page(params[:page])
  end

  # GET /asserted_environments/new
  #   There is no standalone create form - see new.html.erb.
  def new
  end

  # GET /asserted_environments/1/edit
  #   AssertedEnvironment can only be updated from its object's own radial
  #   menu (its ENVO term must come from an autoselect/autocomplete, and its
  #   object can not be changed) - see edit.html.erb.
  def edit
  end

  # POST /asserted_environments.json
  def create
    @asserted_environment = AssertedEnvironment.new(asserted_environment_params)

    if @asserted_environment.save
      render :show, status: :created, location: @asserted_environment
    else
      render json: @asserted_environment.errors, status: :unprocessable_content
    end
  end

  # PATCH/PUT /asserted_environments/1.json
  def update
    if @asserted_environment.update(asserted_environment_params)
      render :show, status: :ok, location: @asserted_environment
    else
      render json: @asserted_environment.errors, status: :unprocessable_content
    end
  end

  # DELETE /asserted_environments/1.json
  def destroy
    if @asserted_environment.destroy
      head :no_content
    else
      render json: @asserted_environment.errors, status: :unprocessable_content
    end
  end

  # GET /asserted_environments/search
  #   TODO: deprecate, see other *_controller#search
  def search
    if params[:id].blank?
      redirect_to asserted_environments_path,
        alert: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to asserted_environment_path(params[:id])
    end
  end

  # GET /asserted_environments/autocomplete.json
  def autocomplete
    @asserted_environments = ::Queries::AssertedEnvironment::Autocomplete.new(
      params.require(:term),
      project_id: sessions_current_project_id
    ).autocomplete
  end

  # GET /asserted_environments/autoselect
  def autoselect
    render json: ::Autoselect::AssertedEnvironment::Autoselect.new(
      term: params[:term],
      level: params[:level],
      project_id: sessions_current_project_id,
      user_id: sessions_current_user_id,
      **autoselect_params
    ).response
  end

  # GET /asserted_environments/object_types
  def object_types
    render json: ENVIRONMENT_ASSERTABLE_TYPES.sort
  end

  private

  def set_asserted_environment
    @asserted_environment = AssertedEnvironment
      .where(project_id: sessions_current_project_id)
      .find(params[:id])
  end

  def asserted_environment_params
    params.require(:asserted_environment).permit(
      :asserted_environment_object_id, :asserted_environment_object_type,
      :uri, :uri_label, :position
    )
  end

  def autoselect_params
    params.permit(:show_info).to_h.symbolize_keys
  end
end
