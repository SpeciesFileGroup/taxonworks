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
  #   the SVG logo(s) for the Organization, as used in this project
  def project_organization_logos_tag(project_organization)
    return nil if project_organization.nil?
    logos = project_organization.logos
    return nil if logos.none?

    logos.collect { |logo|
      image_tag(logo.image.image_file.url, alt: project_organization_tag(project_organization), class: 'logo')
    }.join.html_safe
  end

end
