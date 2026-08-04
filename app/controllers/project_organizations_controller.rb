class ProjectOrganizationsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_project_organization, only: %i[show destroy]
  after_action -> { set_pagination_headers(:project_organizations) }, only: [:index], if: :json_request?

  before_action :require_superuser_sign_in, only: [:destroy, :create]

  # GET /project_organizations
  # GET /project_organizations.json
  def index
    respond_to do |format|
      format.html {
        @recent_objects = Organization.where(project_id: sessions_current_project_id).created_this_week.order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      }
      format.json {
        @project_organizations = ProjectOrganization.where(project_id: sessions_current_project_id)
          .includes(organization: [:depictions])
          .page(params[:page])
          .per(params[:per])
      }
    end
  end

  # GET /project_organizations/1.json
  def show
  end

  def list
    @organizations = Organization.joins(:project_organizations).where(project_organizations: {project_id: sessions_current_project_id}).page(params[:page])
    render '/organizations/list'
  end

  # POST /project_organizations
  # POST /project_organizations.json
  def create
    @project_organization = ProjectOrganization.new(project_organization_params)

    respond_to do |format|
      if @project_organization.save
        format.html { redirect_to @project_organization, notice: 'Organization was successfully added to the project.' }
        format.json { render :show, status: :created, location: @project_organization }
      else
        format.html {
          flash[:notice] = "Failed to add the organization to the project. #{@project_organization.error_messages}."
          redirect_to project_organizations_path
        }
        format.json { render json: @project_organization.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /project_organizations/1
  # DELETE /project_organizations/1.json
  def destroy
    respond_to do |format|
      if @project_organization.destroy
        format.html { redirect_to project_organizations_path, status: :see_other, notice: 'Organization was successfully removed from the project.' }
        format.json { head :no_content }
      else
        format.html {
          flash[:notice] = @project_organization.error_messages.join('; ')
          redirect_to project_organizations_path
        }
        format.json { render json: @project_organization.errors, status: :unprocessable_content }
      end
    end
  end

  # GET /project_organizations/download
  def download
    send_data Export::CSV.generate_csv(
      ProjectOrganization.where(project_id: sessions_current_project_id)), type: 'text', filename: "project_organizations_#{DateTime.now}.tsv"
  end

  def autocomplete
    @organizations = Queries::Organization::Autocomplete.new(params.require(:term)).autocomplete
    render 'organizations/autocomplete'
  end

  private

  def set_project_organization
    @project_organization = ProjectOrganization.where(project_id: sessions_current_project_id).find(params[:id])
  end

  def project_organization_params
    params.require(:project_organization).permit(:organization_id)
  end

end
