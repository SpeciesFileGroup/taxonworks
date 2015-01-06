module TaxonNameRelationshipsHelper

  def taxon_name_relationship_tag(taxon_name_relationship)
    return nil if taxon_name_relationship.nil?
    taxon_name_relationship.to_param
    taxon_name_tag(taxon_name_relationship.subject_taxon_name) + " " + content_tag(:mark, taxon_name_relationship.class.assignment_method.to_s.humanize) + " " + taxon_name_tag(taxon_name_relationship.object_taxon_name)
  end

end
