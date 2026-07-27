module OrganizationsHelper

  def organization_tag(organization)
    return nil if organization.nil?
    organization.name
  end

  def organization_autocomplete_tag(organization, term = nil)
    mark_tag(organization_tag(organization), term)
  end

end
