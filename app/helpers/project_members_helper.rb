module ProjectMembersHelper

  def add_project_member_link
    if @sessions_current_user.is_superuser?
      link_to('Add project member', new_project_member_path(project_member: {project_id: @sessions_current_project_id}))
    else
      nil
    end
  end

end
