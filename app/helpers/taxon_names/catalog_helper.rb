# Helpers for catalog rendering.  See also helpers/lib/catalog_helper.rb
# Each history_ method must generate a span
#
module TaxonNames::CatalogHelper

  def nomenclature_catalog_entry_item_tag(catalog_entry_item) # may need reference_object
    nomenclature_line_tag(catalog_entry_item, catalog_entry_item.base_object) # second param might be wrong!
  end

  # TODO: rename reference_taxon_name
  def nomenclature_catalog_li_tag(nomenclature_catalog_item, reference_taxon_name, target = :browse_nomenclature_task_path)
    content_tag(
      :li,
      (content_tag(:span, nomenclature_line_tag(nomenclature_catalog_item, reference_taxon_name, target)) + ' ' + radial_annotator(nomenclature_catalog_item.object)).html_safe, 
      class: [:history__record, :middle, :inline],
      data: nomenclature_catalog_li_tag_data_attributes(nomenclature_catalog_item)
    ) 
  end

  # TODO: move to Catalog json data attributes helper
  def nomenclature_catalog_li_tag_data_attributes(nomenclature_catalog_item)
    n = nomenclature_catalog_item
    data = {
      'history-origin' => n.origin,
      'history-object-id' => n.object.id,
      'history-valid-name' => (n.is_valid_name? && n.is_first), # marks the single current valid name for this record
      'history-is-subsequent' => !n.is_first # is_subsequent?
    }
    data
  end

  # TODO: rename reference_taxon_name
  def nomenclature_line_tag(nomenclature_catalog_entry_item, reference_taxon_name, target = :browse_nomenclature_task_path)
    i = nomenclature_catalog_entry_item
    t = i.base_object # was taxon_name 
    c = i.citation
    r = reference_taxon_name

    [ 
      history_taxon_name(t, r, c, target),        # the subject, or protonym
      history_author_year(t, c),                  ## author year of the subject, or protonym
      history_subject_original_citation(i),       ##
      history_other_name(i, r),                   # The TaxonNameRelaltionship
      history_in_taxon_name(t, c, i),                ##  citation for related name
      history_pages(c),                           ##  pages for citation of related name
      history_statuses(i),                        # TaxonNameClassification summary
      history_citation_notes(c),                  # Notes on the citation
      history_topics(c),                          # Topics on the citation
      history_type_material(i),
    ].compact.join.html_safe
  end

  def history_taxon_name(taxon_name, r, c, target = nil)
    name = original_taxon_name_tag(taxon_name)
    body = nil
    css = nil
    soft_validation = nil

    if target
      body = link_to(name, send(target, taxon_name_id: taxon_name.id) )
    else
      body = name 
    end

    if taxon_name == r
      css = 'history__reference_taxon_name'
    else
      css = 'history__related_taxon_name' 
      soft_validation = soft_validation_alert_tag(taxon_name)
    end

    content_tag(:span, body + soft_validation.to_s, class: [css, original_citation_css(taxon_name, c), :history__taxon_name ]) 
  end

  # @return [String]
  #   the name, or citation author year, prioritized by original/new with punctuation
  def history_author_year(taxon_name, citation)
    return content_tag(:span, 'Source is verbatim, requires parsing', class: 'feedback feedback-thin feedback-warning') if citation.try(:source).try(:type) == 'Source::Verbatim'
    str =  history_author_year_tag(taxon_name)
    return nil if str.blank?
    if citation
      a = history_author_year_tag(taxon_name)
      b = source_author_year_tag(citation.source)
    end

    if citation.blank? || a != b
      content_tag(:span, ' ' + str, class: [:history_author_year])
    else
      content_tag(:em, ' ') + link_to(content_tag(:span, str, title: strip_tags(citation.source.cached), class: 'history__pages'), send(:nomenclature_by_source_task_path, source_id: citation.source.id) )
    end
#    str.blank? ? nil :
#      content_tag(:span, ' ' + str, class: [:history_author_year])
  end

  # @return [String, nil]
  #   variably return the author year for taxon name in question
  #   !! NO span, is used in comparison !!
  def history_author_year_tag(taxon_name)
    return nil if taxon_name.nil? || taxon_name.cached_author_year.nil?
   
    body =  case taxon_name.type
    when 'Combination'
      current_author_year(taxon_name)
    when 'Protonym'
      original_author_year(taxon_name)
    else
      'HYBRID NOT YET HANDLED'
    end
  end

  # @return [String, nil]
  #   a parenthesized line item containing relationship and related name
  def history_other_name(catalog_item, reference_taxon_name)
    if catalog_item.from_relationship? 
      other_str = nil

      if catalog_item.other_name == reference_taxon_name
        other_str = full_original_taxon_name_tag(catalog_item.other_name)
      elsif catalog_item.object.subject_status_tag == 'classified as'
        other_str = link_to(taxon_name_tag(catalog_item.other_name), browse_nomenclature_task_path(taxon_name_id: catalog_item.other_name.id) ) + ' ' + original_author_year(catalog_item.other_name)
      else
        other_str = link_to(original_taxon_name_tag(catalog_item.other_name), browse_nomenclature_task_path(taxon_name_id: catalog_item.other_name.id) ) + ' ' + original_author_year(catalog_item.other_name)
      end
      content_tag(:span, " (#{catalog_item.object.subject_status_tag} #{other_str})#{soft_validation_alert_tag(catalog_item.object)}".html_safe, class: [:history__other_name])
    end
  end

  # @return [String, nil]
  #   A brief summary of the validity of the name (e.g. 'Valid')
  #     ... think this has to be refined, it doesn't quite make sense to show multiple status per relationship
  def history_statuses(nomenclature_catalog_entry_item)
    i = nomenclature_catalog_entry_item
    s = i.base_object.taxon_name_classifications_for_statuses
    return nil if (s.empty? || !i.is_first) # is_subsequent?
    return nil if i.from_relationship?

    content_tag(:span, class: [:history__statuses]) do
      (' (' +
       s.collect{|tnc|
        content_tag(:span, (tnc.classification_label + soft_validation_alert_tag(tnc).to_s + (tnc.citations.load.any? ? (content_tag(:em, ' in ') + citations_tag(tnc)).html_safe : '') ).html_safe, class: ['history__status'])
      }.join('; ')
      ).html_safe +
      ')'
    end.to_s
  end

  # @return [String, nil]
  #   the taxon name author year for the citation in question
  #   if the same as the author/year for the catalog_item taxon name then this
  #   only renders the pages in that citation
  def history_subject_original_citation(catalog_item)
    return nil if !catalog_item.from_relationship? || catalog_item.object.subject_taxon_name.origin_citation.blank?
    return nil if catalog_item.from_relationship?
    t = catalog_item.object.subject_taxon_name
    c = t.origin_citation

    a = history_author_year_tag(t)
    b = source_author_year_tag(c.source)

    body =  [
      (a != b ?  source_author_year_tag(c.source) : nil) #,
      #history_pages(c)
    ].compact.join.html_safe

    unless body.blank?
      content_tag(:em, ': ') + link_to(content_tag(:span, body, title: strip_tags(c.source.cached), class: :history__subject_original_citation), send(:nomenclature_by_source_task_path, source_id: c.source.id) )
    end
#    content_tag(:span, body, class: :history__subject_original_citation) unless body.blank?
  end

  # @return [String, nil]
  #    return the citation author/year if differeing from the taxon name author year 
  def history_in_taxon_name(t, c, i)
    if c
      a = history_author_year_tag(t) 
      b = source_author_year_tag(c.source)

      tn = t.type == 'Combination' ? t.protonyms.last : t
      if tn.nomenclatural_code == :icn
        in_str = ' ex '
      else
        in_str = ' in '
      end

      if a != b || i.from_relationship?
        content_tag(:em, in_str) + link_to(content_tag(:span, b, title: strip_tags(c.source.cached), class: :history__subject_original_citation), send(:nomenclature_by_source_task_path, source_id: c.source.id) )
#        return content_tag(:span,  content_tag(:em, ' in ') + b, class: [:history__in])
      end
    end
  end
  
  def history_type_material(entry_item)
    return nil if entry_item.object_class != 'Protonym' || !entry_item.is_first # is_subsequent?
    type_taxon_name_relationship = entry_item.base_object&.type_taxon_name_relationship
    
    str = citations_tag(type_taxon_name_relationship) if type_taxon_name_relationship

    [ content_tag(:span, ' '.html_safe + type_taxon_name_relationship_tag(entry_item.base_object.type_taxon_name_relationship), class: 'history__type_information'),

#      citations_tag(entry_item.base_object&.type_taxon_name_relationship)
#      (entry_item.base_object&.type_taxon_name_relationship&.citations&.load&.any? ? (content_tag(:em, ' in ') + citations_tag(entry_item.base_object&.type_taxon_name_relationship)) : '')
    (type_taxon_name_relationship&.citations&.load&.any? ? (content_tag(:em, ' in ') +
        link_to(content_tag(:span, str, title: strip_tags(type_taxon_name_relationship&.citations&.first&.source&.cached), class: 'history__pages'), send(:nomenclature_by_source_task_path, source_id: type_taxon_name_relationship&.citations&.first&.source&.id) )  ) : '')


    #      history_in(entry_item.base_object&.type_taxon_name_relationship&.source)
    ].compact.join.html_safe
  end

  def taxon_name_synonym_li(syn)
    label = [
      content_tag(:span, "Syn. "), 
      link_to(full_original_taxon_name_label(syn) || taxon_name_label(syn), browse_nomenclature_task_path(taxon_name_id: syn.id))
    ].compact.join.html_safe

    content_tag(:li, label)
  end

  def taxon_name_synonyms_list(taxon_name)
    synonyms = taxon_name&.synonyms.where.not(id: taxon_name.id)&.order(:cached, :cached_author_year).uniq
  end

end
