class RolesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  # include ShallowPolymorphic

  before_action :set_role, only: [:update, :destroy]
 # after_action -> { set_pagination_headers(:roles) }, only: [:index, :api_index ], if: :json_request?

# # GET /roles
# # GET /roles.json
# # GET /<model>/:id/roles.json
# def index
#   respond_to do |format|
#     format.html {
#       @recent_objects = Role.where(project_id: sessions_current_project_id).order(updated_at: :desc).limit(10)
#       render '/shared/data/all/index'
#     }
#     format.json {
#       @roles = Queries::Role::Filter.new(filter_params)
#         .all
#         .page(params[:page])
#         .per(params[:per])
#     }
#   end
# end

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

    respond_to do |format|
      if @role.save
   #    format.html { redirect_to url_for(@role.role_object.metamorphosize),
   #                  notice: 'Role was successfully created.' }
        format.json { render json: @role, status: :created, location: @role }
      else
   #    format.html { redirect_back(fallback_location: (request.referer || root_path),
   #                                notice: 'Role was NOT successfully created.') }
        format.json { render json: @role.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /roles/1
  # PATCH/PUT /roles/1.json
  def update
    respond_to do |format|
      if @role.update(role_params)
   #     format.html { redirect_to url_for(@role.role_object.metamorphosize),
   #                   notice: 'Role was successfully created.' }
        format.json { render action: 'show', status: :created, location: @role }
      else
   #     format.html { redirect_back(fallback_location: (request.referer || root_path),
   #                                 notice:            'Role was NOT successfully updated.') }
        format.json { render json: @role.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /roles/1
  # DELETE /roles/1.json
  def destroy
    @role.destroy
    respond_to do |format|
      # TODO: probably needs to be changed
      format.html { destroy_redirect @role, notice: 'Role was successfully destroyed.' }
      format.json { head :no_content }
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
    #@role = Role.where(project_id: sessions_current_project_id).find(params[:id])
    
    # TODO: confirm Role is in project if annotated object is provided
    @role = Role.find(params[:id])
  end

  def role_params
    params.require(:role).permit(
      :person_id,
      :role_object_id, :role_object_type,
      :annotated_global_entity)
  end

end
