class ProjectMembersController < ApplicationController
  before_action :require_superuser_sign_in 
  before_action :set_project_member, only: [:edit, :update, :destroy]
  before_action :set_form_variables, only: [:new, :create]

  def set_form_variables
    @available_users = User.all.not_in_project(sessions_current_project_id).order(:name)
    @target_letters = @available_users.collect{|u| u.name[0].upcase}.uniq
  end

  # GET /project_members/new
  def new
    redirect_to hub_path, notice: 'Select a project first.' if !sessions_project_selected?
    @project_member = ProjectMember.new(project_id: sessions_current_project_id)
    redirect_to project_path(@project_member.project), alert: 'There are no additional users available to add to this project.' if !@available_users.any?
  end

  # GET /project_members/1/edit
  def edit
  end

  # POST /project_members
  def create

    project = Project.find(sessions_current_project)

    begin

      ActiveRecord::Base.transaction do
        project_members_params[:user_ids].each do |user_id|
          project.project_members.create!(project_member_params.merge(user_id: user_id)) 
        end 
      end

      @project_member = ProjectMember.new(project_member_params)
      redirect_to project_path(sessions_current_project_id), notice: "Project members were added to project." 

    rescue ActiveRecord::RecordInvalid
      render :new 
    end
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
    # Use callbacks to share common setup or constraints between actions.
    def set_project_member
      @project_member = ProjectMember.where(project_id: sessions_current_project_id).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_member_params
      params.require(:project_member).permit(:project_id, :is_project_administrator)
    end

    def project_members_params
      params.require(:project_member).permit(user_ids: [])
    end
end
