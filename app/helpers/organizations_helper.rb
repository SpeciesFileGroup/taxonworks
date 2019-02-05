module OrganizationsHelper

  def organization_tag(organization)
    return nil if organization.nil?
    organization.name
  end

end
