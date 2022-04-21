# A controller include, need to split out session methods
# versus those that aren't
#
module ProjectsHelper

  def project_tag(project)
    return nil if project.nil?
    project.name
  end

  def projects_search_form
    render('/projects/quick_search_form')
  end

  def project_link(project)
    return nil if project.nil?
    l = link_to(project.name, select_project_path(project))
    project.id == sessions_current_project_id ?
      content_tag(:mark, l) :
      l
  end

  def projects_list(projects)
    projects.collect { |p| content_tag(:li, project_link(p)) }.join.html_safe
  end

  def project_login_link(project)
    return nil unless (!is_project_member_by_id?(sessions_current_user_id, sessions_current_project_id) && (sessions_current_project_id != project.id))
    link_to('Login to ' + project.name, select_project_path(project), class: ['button-default'])
  end

  def invalid_object(object)
    !(!object.try(:project_id) || project_matches(object))
  end

  def project_matches(object)
    object.try(:project_id) == sessions_current_project_id
  end

end
