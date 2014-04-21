# A controller include, need to split out session methods
# verus those that aren't
module ProjectsHelper

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
