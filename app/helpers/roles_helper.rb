module RolesHelper

  def roles_names(roles)
    people_names(roles.collect{|p| p.person}) 
  end

  def role_tag(role)
    return nil if role.nil?
    person_tag(role.person)
  end

  def role_link(role)
    return nil if role.nil?
    link_to(role_tag(role).html_safe, metamorphosize_if(role.role_object))
  end  

end
