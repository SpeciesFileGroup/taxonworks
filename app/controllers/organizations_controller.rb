class OrganizationsController < ApplicationController
  include DataControllerConfiguration::SharedDataControllerConfiguration

  before_action :set_organization, only: [:show, :edit, :update, :destroy]

  # GET /organizations
  # GET /organizations.json
  def index
    respond_to do |format|
      format.html do
        @recent_objects = Organization.created_this_week.order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      end
      format.json {
        # @organizations = Queries::Organization::Filter.new(filter_params).all.with_project_id(sessions_current_project_id)
      }
    end
  end

  # GET /organizations/1
  # GET /organizations/1.json
  def show
  end

  # GET /organizations/new
  def new
    @organization = Organization.new
  end

  # GET /organizations/1/edit
  def edit
  end

  # POST /organizations
  # POST /organizations.json
  def create
    @organization = Organization.new(organization_params)

    respond_to do |format|
      if @organization.save
        format.html { redirect_to @organization, notice: 'Organization was successfully created.' }
        format.json { render :show, status: :created, location: @organization }
      else
        format.html { render :new }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /organizations/1
  # PATCH/PUT /organizations/1.json
  def update
    respond_to do |format|
      if @organization.update(organization_params)
        format.html { redirect_to @organization, notice: 'Organization was successfully updated.' }
        format.json { render :show, status: :ok, location: @organization }
      else
        format.html { render :edit }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /organizations/1
  # DELETE /organizations/1.json
  def destroy
    @organization.destroy
    respond_to do |format|
      format.html { redirect_to organizations_url, notice: 'Organization was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # Meh- term/query_string needs unification
  def autocomplete
    @organizations = Queries::Organization::Autocomplete.new(params.require(:term)).autocomplete
  end

  def list
    @organizations = Organization.page(params[:page])
  end

  private

  def set_organization
    @organization = Organization.find(params[:id])
  end

  def organization_params
    params.require(:organization).permit(
      :name, :alternate_name, :description, :disambiguating_description,
      :same_as_id, :address, :email, :telephone, :duns, :global_location_number,
      :legal_name, :area_served_id, :department_id, :parent_organization_id
    )
  end
end
