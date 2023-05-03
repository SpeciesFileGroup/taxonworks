class ProjectMembersController < ApplicationController

  before_action :require_superuser_sign_in, except: [:update_clipboard, :index, :clipboard]
  before_action :require_sign_in_and_project_selection, only: [:update_clipboard, :clipboard]

  before_action :set_project_member, only: [:edit, :update, :destroy]
  before_action :set_member_project, only: [:many_new, :new, :create_many]
  before_action :set_available_users, only: [:many_new, :new]
  before_action :set_form_variables, only: [:many_new]

  # GET /project_members.json
  def index
    @project_members = ProjectMember.joins(:user).where(project_id: sessions_current_project_id).order('users.name ASC').includes(:user)
  end

  # GET /project_members/new
  def new
    @project_member = ProjectMember.new(project_member_params)
    redirect_to project_path(@project_member.project), alert: 'There are no additional users available to add to this project.' if !@available_users.any?
  end

  # GET /project_members/1/edit
  def edit
  end

  # POST /otus
  def create
    @project_member = ProjectMember.new(project_member_params)

    respond_to do |format|
      if @project_member.save
        format.html { redirect_to project_path(@project_member.project),
                      notice: "User #{@project_member.user.name}' was successfully added to #{@project_member.project.name}." }
      else
        set_available_users
        format.html { render action: 'new' }
      end
    end
  end

  # POST /project_members/create_many
  def create_many
    begin
      ApplicationRecord.transaction do
        project_members_params.each do |user_id|
          @member_project.project_members.create!(project_member_params.merge(user_id: user_id))
        end
      end

      @project_member = ProjectMember.new(project_member_params)
      redirect_to project_path(@member_project), notice: "Project members were #{project_members_params.empty? ? 'not selected.' : 'added to project.'}"

    rescue ActiveRecord::RecordInvalid
      redirect_to many_new_project_members_path, notice: 'There was a problem adding project members, none were added.'
    end
  end

  def many_new
    @project_member = ProjectMember.new(project_member_params)
    redirect_to project_path(@project_member.project), alert: 'There are no additional users available to add to this project.' if !@available_users.any?
  end

  # PATCH/PUT /project_members/1
  # PATCH/PUT /project_members/1.json
  def update
    respond_to do |format|
      if @project_member.update(project_member_params)
        format.html { redirect_to  project_path(@project_member.project), notice: 'Project member was successfully updated.' }
        format.json { render :show, status: :ok, location: @project_member }
      else
        format.html { render :edit }
        format.json { render json: @project_member.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH /project_members/1/update_clipboard.json
  def update_clipboard
    @project_member = sessions_current_user.project_members.where(project_id: sessions_current_project_id).first  
    if @project_member.update( params.require(:project_member).permit(clipboard: {}) )
      render :show, status: :ok, location: @project_member 
    else
      render json: @project_member.errors, status: :unprocessable_entity 
    end
  end

  def clipboard
    if @project_member = sessions_current_user.project_members.where(project_id: sessions_current_project_id).first
      render :show
    else
      render json: {}
    end
  end

  # DELETE /project_members/1
  # DELETE /project_members/1.json
  def destroy
    @project_member.destroy
    respond_to do |format|
      format.html { redirect_to project_path(@project_member.project), notice: 'Project member was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_available_users
    @available_users = User.all.not_in_project(@member_project).order(:name)
  end

  def set_form_variables
    @target_letters = @available_users.collect {|u| u.name[0].upcase}.uniq
  end

  def set_project_member
    @project_member = ProjectMember.find(params[:id])
  end

  def set_member_project
    @member_project = Project.find(project_id_param)
  end

  def project_member_params
    params.require(:project_member).permit(:project_id, :is_project_administrator, :user_id)
  end

  def project_members_params
    params.require(:project_member).permit(user_ids: [])[:user_ids] || []
  end

  def project_id_param
    params.require(:project_member).permit(:project_id)[:project_id]
  end

end
