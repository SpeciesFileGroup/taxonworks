module TaxonNameRelationshipsHelper

  def taxon_name_relationship_tag(taxon_name_relationship)
    return nil if taxon_name_relationship.nil?
    taxon_name_tag(taxon_name_relationship.subject_taxon_name) + " " + content_tag(:span, taxon_name_relationship.class.assignment_method.to_s.humanize, class: :subtle) + " " + taxon_name_tag(taxon_name_relationship.object_taxon_name)
  end

  # @return [String]
  #   subject + relationship type 
  def taxon_name_relationship_for_subject_tag(taxon_name_relationship)
    return nil if taxon_name_relationship.nil?

    content_tag(:span, taxon_name_relationship.class.subject_relationship_name, class: :string_emphasis)  + " " +    taxon_name_link(taxon_name_relationship.object_taxon_name) 
  end

  # @return [String]
  #  relationship_type + object
  def taxon_name_relationship_for_object_tag(taxon_name_relationship)
    return nil if taxon_name_relationship.nil?
     taxon_name_link(taxon_name_relationship.subject_taxon_name)  + " " + content_tag(:span, taxon_name_relationship.class.object_relationship_name, class: :string_emphasis) 
  end

end
