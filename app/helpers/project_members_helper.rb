module ProjectMembersHelper 
  
  def add_project_member_link(project_id)
    link_to('Add project member', new_project_member_path(project_member: {project_id: project_id} )) if is_superuser?
  end

end
