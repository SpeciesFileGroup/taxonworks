class ProjectsController < ApplicationController
  before_action :require_sign_in
  before_action :require_administrator_sign_in, only: [:new, :create, :index, :destroy]
  before_action :require_superuser_sign_in, only: [:show, :edit, :update]
  before_action :set_project, only: [:show, :edit, :update, :destroy, :select]

  # GET /projects
  # GET /projects.json
  def index
    @projects = Project.all
    @recent_objects = Project.order(updated_at: :desc).limit(10)
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
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url }
      format.json { head :no_content }
    end
  end

  def select
    set_project
    if authorize_project_selection(sessions_current_user, @project)
      sessions_select_project(@project)
      redirect_to @project.workbench_starting_path
    else
      redirect_to root_path, notice: 'You are not a member of that project!'
    end
  end

  def settings_for
    redirect_to otus_path, notice: 'Project settings not yet implemented'
  end

  def list
    @projects = Project.order(:id).page(params[:page]) #.per(10) #.per(3)
  end

  def search
    redirect_to project_path(params[:project][:id])
  end

  def autocomplete
    @projects = Project.find_for_autocomplete(params)

    data = @projects.collect do |t|
      {id:              t.id,
       label:           ProjectsHelper.project_tag(t),
       response_values: {
         params[:method] => t.id
       },
       label_html:      ProjectsHelper.project_tag(t) #  render_to_string(:partial => 'shared/autocomplete/taxon_name.html', :object => t)
      }
    end

    render :json => data
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_project
    @project = Project.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def project_params
    params.require(:project).permit(:name)
  end
end
