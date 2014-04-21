module ProjectsHelper

  def sessions_project_selected?
    !sessions_current_project_id.nil?
  end

  def sessions_current_project_id=(project_id)
    @sessions_current_project_id = project_id
  end

  def sessions_current_project_id
    @sessions_current_project_id = session[:project_id]
  end

  def sessions_current_project
   return nil unless sessions_current_project_id 
   @sessions_current_project ||= Project.find(@sessions_current_project_id)
  end

  def sessions_select_project(project)
   self.sessions_current_project_id = project.id
   session[:project_id] = @sessions_current_project_id 
   @sessions_current_project ||= Project.find(@sessions_current_project_id)
  end

  def sessions_clear_selected_project
    session[:project_id] = nil
  end

  def project_link(project)
    l = link_to(project.name, select_project_path(project))
    project.id == session[:project_id] ?
      content_tag(:mark, l) :
      l 
  end

  def projects_list(projects)
    projects.collect{|p| content_tag(:li, project_link(p)) }.join.html_safe
  end

end
