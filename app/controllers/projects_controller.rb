class ProjectsController < ApplicationController
  before_action :require_sign_in
  before_action :require_administrator_sign_in, only: [:new, :create, :destroy]
  before_action :require_superuser_sign_in, only: [:show, :edit, :update]
  before_action :can_administer_projects?, only: [:index]

  before_action :set_project, only: [:show, :edit, :update, :destroy, :select, :stats, :recently_created_stats, :per_relationship_recent_stats]

  # GET /projects
  # GET /projects.json
  def index
    @projects = Project.all
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(project_params)

    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render action: 'show', status: :created, location: @project }
      else
        format.html { render action: 'new' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render action: 'edit' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    redirect_to projects_url, notice: 'Nice try, not this time.'
  end

  def preferences
    @project = sessions_current_project
  end

  def select
    set_project
    if authorize_project_selection(sessions_current_user, @project)
      sessions_select_project(@project)
      redirect_to go_to # see def go_to for unprotected redirect mitigation
    else
      redirect_to root_path, notice: 'You are not a member of that project!'
    end
  end

  def settings_for
    redirect_to edit_project_path(sessions_current_project)
  end

  def stats
    Rails.application.eager_load!
  end

  def per_relationship_recent_stats
    Rails.application.eager_load!
    @relationship = params.require(:relationship) # params.permit(:relationship)[:relationship]
  end

  def list
    @projects = Project.order(:id).page(params[:page]) #.per(10) #.per(3)
  end

  def search
    if params[:id].blank?
      redirect_to projects_path, alert: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to project_path(params[:id])
    end
  end

  def autocomplete
    @projects = Project.find_for_autocomplete(params)

    data = @projects.collect do |t|
      {id: t.id,
       label: ApplicationController.helpers.project_tag(t),
       response_values: {
           params[:method] => t.id
       },
       label_html: ApplicationController.helpers.project_tag(t)
      }
    end

    render json: data
  end

  def recently_created_stats
    redirect_to hub_path, notice: 'Select a project first.' if @project.nil?
    render json: @project.data_breakdown_for_chartkick_recent
  end

  private

  def set_project
    @project = Project.find(params[:id])
    @recent_object = @project
  end

  def project_params
      params.require(:project).permit(:name, :set_new_api_access_token, :clear_api_access_token, Project.key_value_preferences, Project.array_preferences, Project.hash_preferences)
  end

  def go_to
    @project.workbench_starting_path
  end

end
