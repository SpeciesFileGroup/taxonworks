module ProjectMembersHelper 
  
  def add_project_member_link(project_id)
    link_to('Add project member', new_project_member_path(project_member: {project_id: project_id} )) if is_superuser?
  end

  def user_last_seen_in_project_tag(project_member)
    if !project_member.last_seen_at.blank?
      time_ago_in_words(project_member.last_seen_at) + '  ago'
    else
      content_tag(:em, 'never')
    end
  end

  # In hours
  def user_time_active_in_project(project_member)
    (project_member.time_active.to_f / 3600.to_f || 0.0).round(1)
  end

  # In hours
  def user_time_active_in_project_tag(project_member)
    t = user_time_active_in_project(project_member)

    if t == 0.0
      nil
    else
      (project_member.time_active.to_f / 3600.to_f || 0.0).round(1).to_s + ' hours'
    end
  end

end
