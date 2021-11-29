class RolesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration
  include ShallowPolymorphic

  before_action :set_role, only: [:update, :destroy]
  after_action -> { set_pagination_headers(:roles) }, only: [:index, :api_index ], if: :json_request?

  # GET /roles.json
  def index
    @roles = Queries::Role::Filter.new(filter_params)
      .all
      .page(params[:page])
      .per(params[:per])
  end

  def new
    @role = Role.new(role_params)
  end

  def edit
    @role = Role.find_by_id(params[:id]).metamorphosize
  end

  # POST /roles
  # POST /roles.json
  def create
    @role = Role.new(role_params)
    if @role.save
      render json: @role, status: :created, location: @role.metamorphosize
    else
      render json: @role.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /roles/1.json
  def update
    if @role.update(role_params)
      render action: 'show', status: :created, location: @role.metamorphosize
    else
      render json: @role.errors, status: :unprocessable_entity
    end
  end

  # DELETE /roles/1.json
  def destroy
    if @role.destroy
      format.json { head :no_content }
    else
      render json: @role.errors, status: :unprocessable_entity
    end
  end

  # # GET /roles/download
  # def download
  #   send_data Export::Download.generate_csv(Role.where(project_id: sessions_current_project_id)),
  #     type: 'text',
  #     filename: "roles_#{DateTime.now}.csv"
  # end

  # # GET /api/v1/roles
  # def api_index
  #   @roles = Queries::Role::Filter.new(api_params).all
  #     .order('roles.id')
  #     .page(params[:page])
  #     .per(params[:per])
  #   render '/roles/api/v1/index'
  # end

  # # GET /api/v1/roles/:id
  # def api_show
  #   render '/roles/api/v1/show'
  # end

  private

  def set_role
    # TODO: confirm Role is in project if annotated object is provided
    @role = Role.find(params[:id])
  end

  def filter_params
    add_project_id = false
    role_types = [params[:role_type]&.safe_constantize]
    if !params[:object_global_id].blank?
      role_types << GlobalID::Locator.locate(params[:object_global_id]).class
    end

    h = params.permit(
      :role_type,
      :object_global_id,
      role_type: [])

    # If any role
    role_types.flatten.compact.uniq.each do |t|
      if t.is_community?
        h['project_id'] = sessions_current_project_id
        break
      end
    end
    h
  end

  def role_params
    params.require(:role).permit(
      :position,
      :type,
      :person_id,
      :role_object_id,
      :role_object_type,
      :organization_id,
      :annotated_global_entity) # not supported yet
  end

end
