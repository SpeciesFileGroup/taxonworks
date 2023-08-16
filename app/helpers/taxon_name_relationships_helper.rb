module TaxonNameRelationshipsHelper

  def taxon_name_relationship_tag(taxon_name_relationship)
    return nil if taxon_name_relationship.nil?
    [
      original_taxon_name_link(taxon_name_relationship.subject_taxon_name),
      content_tag(:span, ( defined?(taxon_name_relationship.class.inverse_assignment_method) ?
      taxon_name_relationship.class.inverse_assignment_method.to_s.humanize :
      taxon_name_relationship.type ) + taxon_name_relationship.subject_status_connector_to_object.to_s,
      class: :subtle),
        taxon_name_browse_link(taxon_name_relationship.object_taxon_name)
      ].compact.join(' ')
    end

    def label_for_taxon_name_relationship(taxon_name_relationship)
      return nil if taxon_name_relationship.nil?
      [
        label_for_taxon_name(taxon_name_relationship.subject_taxon_name),
        defined?(taxon_name_relationship.class.inverse_assignment_method) ?  taxon_name_relationship.class.inverse_assignment_method.to_s.humanize : taxon_name_relationship.type,
        label_for_taxon_name(taxon_name_relationship.object_taxon_name)
      ].compact.join(' ')
    end

    # @return [String]
    #   subject + relationship type
    def taxon_name_relationship_for_subject_tag(taxon_name_relationship)
      return nil if taxon_name_relationship.nil?
      [
        content_tag(:span, taxon_name_relationship.subject_status_tag , class: :string_emphasis),
        original_taxon_name_link(taxon_name_relationship.object_taxon_name),
        taxon_name_relationship.object_taxon_name.cached_author_year
      ].join(' ').html_safe
    end

    # @return [String]
    #  relationship_type + object
    def taxon_name_relationship_for_object_tag(taxon_name_relationship)
      [
        content_tag(:span, taxon_name_relationship.object_status_tag, class: :string_emphasis),
        original_taxon_name_link(taxon_name_relationship.subject_taxon_name),
        taxon_name_relationship.subject_taxon_name.cached_author_year
      ].join(' ').html_safe
    end

    def type_taxon_name_relationship_tag(taxon_name_relationship, target: :browse_nomenclature_task_path)
      return nil if taxon_name_relationship.nil?
      # TODO: add original citation to relationship rendering (conflicts with paper catalog/browse nomenclature use if you do this!)
      content_tag(:span, [ taxon_name_relationship.subject_status,
        link_to( original_taxon_name_tag( taxon_name_relationship.subject_taxon_name), send(target, taxon_name_id: taxon_name_relationship.subject_taxon_name.id)),
        original_author_year(taxon_name_relationship.subject_taxon_name)].join(' ').html_safe, class: 'type_information'
      )
    end

    def type_taxon_name_relationship_label(taxon_name_relationship, target: :browse_nomenclature_task_path)
      return nil if taxon_name_relationship.nil?
      [ taxon_name_relationship.subject_status,
        original_taxon_name_tag( taxon_name_relationship.subject_taxon_name),
        original_author_year(taxon_name_relationship.subject_taxon_name)
      ].join(' ').html_safe
    end

  end

