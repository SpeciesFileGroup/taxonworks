module ProjectsHelper

  def projects_list(projects)
    projects.collect{|p| content_tag(:li, link_to(p.name, select_project_path(p))) }.join.html_safe
  end

  def sessions_project_selected?
    !sessions_current_project.nil?
  end

  def sessions_current_project=(project)

  end

  

end
