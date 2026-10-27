module ProjectOrganizationsHelper

  def project_organization_tag(project_organization)
    return nil if project_organization.nil?
    organization_tag(project_organization.organization)
  end

  def project_organization_autocomplete_tag(project_organization)
    project_organization_tag(project_organization)
  end

  def label_for_project_organization(project_organization)
    return nil if project_organization.nil?
    project_organization_tag(project_organization)
  end

  # @return [String, nil]
  #   the Organization's depictions, as used in this project
  def project_organization_depictions_tag(project_organization)
    return nil if project_organization.nil?
    depictions = project_organization.depictions
    return nil if depictions.none?

    depictions.collect { |depiction|
      depiction_tag(depiction, size: :thumb)
    }.join.html_safe
  end

end
