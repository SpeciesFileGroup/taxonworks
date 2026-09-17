class AssertedEnvironmentsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_asserted_environment, only: [:show, :update, :destroy]
  after_action -> { set_pagination_headers(:asserted_environments) }, only: [:index], if: :json_request?

  # GET /asserted_environments.json
  def index
    @asserted_environments = ::Queries::AssertedEnvironment::Filter.new(params).all
      .where(project_id: sessions_current_project_id)
      .includes(:asserted_environment_object)
      .order(:cached, :id)
      .page(params[:page]).per(params[:per] || 500)
  end

  # GET /asserted_environments/1.json
  def show
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
