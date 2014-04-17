module ProjectsHelper

  def sessions_project_selected?
    !sessions_current_project_id.nil?
  end

  def session_current_project_id
    session[:project_id]
  end

  def sessions_current_project_id=(project)
    session[:project_id] = project.id 
  end

  def sessions_current_project
    Project.find(sessions[:project_id]) 
  end

  def sessions_clear_selected_project
    session[:project_id] = nil
  end

  def projects_list(projects)
    projects.collect{|p| content_tag(:li, link_to(p.name, select_project_path(p))) }.join.html_safe
  end
  

end
