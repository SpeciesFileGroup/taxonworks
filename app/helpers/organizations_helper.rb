module OrganizationsHelper

  def organization_tag(organization)
    return nil if organization.nil?
    organization.name
  end

  def organization_link(organization)
    return nil if organization.nil?
    link_to(organization_tag(organization), organization.metamorphosize).html_safe
  end

end
