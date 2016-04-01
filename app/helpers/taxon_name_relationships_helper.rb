module TaxonNameRelationshipsHelper

  def taxon_name_relationship_tag(taxon_name_relationship)
    return nil if taxon_name_relationship.nil?
    [
      taxon_name_tag(taxon_name_relationship.subject_taxon_name),
      taxon_name_relationship.subject_taxon_name.cached_author_year ,
      content_tag(:span, ( defined?(taxon_name_relationship.class.assignment_method) ? 
                          taxon_name_relationship.class.assignment_method.to_s.humanize : 
                          taxon_name_relationship.type ),
                          class: :subtle),
      taxon_name_tag(taxon_name_relationship.object_taxon_name),
      taxon_name_relationship.object_taxon_name.cached_author_year].join(' ')
  end

  # @return [String]
  #   subject + relationship type 
  def taxon_name_relationship_for_subject_tag(taxon_name_relationship)
    return nil if taxon_name_relationship.nil?
    content_tag(:span, taxon_name_relationship.subject_relationship_name) + 
      ' (See ' + taxon_name_link(taxon_name_relationship.object_taxon_name) + 
      (taxon_name_relationship.subject_taxon_name.cached_valid_taxon_name_id ?  # test for nil, it's not always being set?!
       ' ' +
       TaxonName.find(taxon_name_relationship.subject_taxon_name.cached_valid_taxon_name_id).try(:cached_author_year) + 
       ')' : nil
      )
  end

  # @return [String]
  #  relationship_type + object
  def taxon_name_relationship_for_object_tag(taxon_name_relationship)
    return nil if taxon_name_relationship.nil?
    [ taxon_name_link(taxon_name_relationship.subject_taxon_name),
      taxon_name_relationship.subject_taxon_name.cached_author_year
    ].join(' ') + content_tag(:span, taxon_name_relationship.object_relationship_name, class: :string_emphasis)
  end

  def type_taxon_name_relationship_tag(taxon_name_relationship)
    return nil if taxon_name_relationship.nil?
    # TODO: add original citation to relationship rendering
    content_tag(:span, [ taxon_name_relationship.object_relationship_name.capitalize,  
                      taxon_name_link(taxon_name_relationship.subject_taxon_name),
                      taxon_name_relationship.subject_taxon_name.cached_author_year ].join(' ').html_safe, class: 'type_information'
               )
  end


  def taxon_name_relationships_search_form
    render '/taxon_name_relationships/quick_search_form'
  end



end
