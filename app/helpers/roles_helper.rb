module RolesHelper

  def role_tag(role)
    return nil if role.nil?

    [(role.person ? role.person.cached : role.organization.name), "[#{role.class.human_name}]"].join(' ').html_safe
  end

  def roles_names(roles)
    Utilities::Strings.authorship_sentence(roles.collect{|role| role.person ? role.person.full_last_name : role.organization.name})
  end

  def role_link(role)
    return nil if role.nil?
    link_to(role_tag(role).html_safe, metamorphosize_if(role.role_object))
  end

  # @return [String, nil]
  #   the role followed by the object tag of the role_object, like 'Taxon name author of <i>Aus bus</i>'.
  def role_object_tag(role)
    return nil if role.nil?
    [role.class.human_name, object_tag(role.role_object)].join(' of ').html_safe
  end

  def role_in_project?(role)
    Role.exists?(project_id: sessions_current_project_id, id: role.id)
  end

end
