module TaxonNamesHelper

  # @return [String] 
  #   the taxon name without author year, with HTML
  def taxon_name_tag(taxon_name)
    return nil if taxon_name.nil?
    return taxon_name.name if taxon_name.new_record?
    # TODO: fix generation of empty string cached author year
    taxon_name.cached_html.html_safe || taxon_name.name
  end

  # @return [String]
  #   the taxon name in original combiantion, without author year, with HTML
  def original_taxon_name_tag(taxon_name)
    return nil if taxon_name.nil?
    taxon_name.cached_original_combination.nil? ? taxon_name.cached_html.html_safe || taxon_name.name : taxon_name.cached_original_combination.html_safe
  end

  # @return [String]
  #  the current name/combination with author year, and HTML
  def full_taxon_name_tag(taxon_name)
    return nil if taxon_name.nil?
    [taxon_name_tag(taxon_name), taxon_name.cached_author_year].compact.join(" ").html_safe
  end

  # @return [String
  #  the name in original combiantion, with author year, and HTML
  def full_original_taxon_name_tag(taxon_name)
    return nil if taxon_name.nil?
    [original_taxon_name_tag(taxon_name), original_author_year(taxon_name)].compact.join(" ").html_safe
  end

  # TODO: !! ug, hackish
  def original_author_year(taxon_name)
    return nil if taxon_name.nil? || taxon_name.cached_author_year.nil?
    taxon_name.cached_author_year.gsub(/^\(|\)$/, '')
  end

  def taxon_name_history_tag(taxon_name, citation)

    # taxon name in original combination
    # taxon name author year
    # { citation author/year }
    # { citation pages }
    # { type information }
    # { status }
    # { citation notes }
    # { citation topics }

    # Each item must be spanned, or generate a span, and classed for styling
    [
      content_tag(:span, original_taxon_name_tag(taxon_name), class: [:original_taxon_name, original_citation_css(taxon_name, citation) ] ), 
      history_author_year(taxon_name, citation),
      history_pages(citation),
      history_statuses(taxon_name, citation), 
      history_notes(citation),
      history_topics(citation),
      history_type_material(taxon_name),
    ].compact.join.html_safe
  end
  
  def original_citation_css(taxon_name, citation)
    return nil if citation.nil?
    'original_description' if citation.is_original? && taxon_name == citation.citation_object
  end

  def history_type_material(taxon_name)
    return nil if taxon_name.type == 'Combination'
    content_tag(:span, type_taxon_name_relationship_tag(taxon_name.type_taxon_name_relationship), class: 'type_information')
  end

  def history_topics(citation)
    return nil if citation.nil?
    content_tag(:span, citation.citation_topics.collect{|t| t.topic.name}.join(", "), class: 'citation_topics')
  end

  def history_notes(citation)
    return nil if citation.nil? || !citation.notes.any?
    content_tag(:span, citation.notes.collect{|n| n.text}.join, class: 'citation_notes') if citation.notes?
  end

  # @return [String, nil]
  #   A brief summary of the validity of the name (e.g. 'Valid')
  #     ... think this has to be refined, it doesn't quite make sense to show multiple status per relationship
  def history_statuses(taxon_name, citation)
    return nil if taxon_name.taxon_name_statuses.empty?
    content_tag(:span, (' (' + taxon_name.taxon_name_statuses.join(', ') + ')').html_safe, class: 'status')
  end

  def history_pages(citation)
    return nil if citation.nil?
    content_tag(:span, ": #{citation.pages}.", class: 'pages') if citation.pages
  end

  # @return [String]
  #   the name, or citation author year, prioritized by original/new with punctuation
  def history_author_year(taxon_name, citation) 
    if citation.try(:is_original) || citation.nil?
      v = original_author_year(taxon_name)
      content_tag(:span, " #{v}", class: 'taxon_name_author_year') if defined? v.length && v.length > 0
    elsif !citation.nil?
      content_tag(:span, '. ' + citation.source.author_year, class: 'citation_author_year') 
    end
  end

  def nomenclature_line_tag(nomenclature_catalog_item)
    i = nomenclature_catalog_item
    c = i.citation

    content_tag(:li, class: :history_record) do
      case i.object_class
      when 'Protonym', 'Combination' 
        taxon_name_history_tag(i.object, i.object.origin_citation)
      when  /TaxonNameRelationship/
        taxon_name_history_tag(i.object.subject_taxon_name, i.object.origin_citation)
      else
        i.object_class
      end
    end

#   content_tag(:li) do  
#     if i.cited?
#       case i.object_class
#       when 'Protonym'
#         taxon_name_nomenclature_line_tag(c) 
#       when  /TaxonNameRelationship/
#         [taxon_name_relationship_for_object_tag(c.annotated_object),  c.citation_topics.collect{|t| t.topic.name}.join(", "), "REL" ].compact.join(" ").html_safe    
#       else 
#         i.object_class
#       end
#     else
#       case i.object_class
#       when 'Protonym' # have to fork vs. Combination
#         [ full_original_taxon_name_tag(i.object), type_taxon_name_relationship_tag(i.object.type_taxon_name_relationship) ].compact.join(". ").html_safe
#       when 'Combination'
#         [ full_original_taxon_name_tag(i.object) ].compact.join(". ").html_safe # , type_taxon_name_relationship_tag(i.object.type_taxon_name_relationship)
#       when  /TaxonNameRelationship/
#         [ full_original_taxon_name_tag(i.object.subject_taxon_name), taxon_name_statuses_tag(i.object.subject_taxon_name)].join(" ").html_safe 
#       else 
#         i.object_class
#       end
#     end
#   end
  end

  def latinization_tag(taxon_name)
    list = TaxonNameClassification.where_taxon_name(@taxon_name).with_type_array(LATINIZED_TAXON_NAME_CLASSIFICATION_NAMES)
    if list.any?
      content_tag(:h3, 'Latinization') +
        list.collect{|c|
        content_tag(:span, c.classification_label) 
      }.join('; ').html_safe 
    end
  end

  def cached_classified_as_tag(taxon_name)
    taxon_name.cached_classified_as ? taxon_name.cached_classified_as.strip.html_safe : ''
  end

  def taxon_name_autocomplete_selected_tag(taxon_name)
    return nil if taxon_name.nil?
    taxon_name.cached
  end

  def taxon_name_link(taxon_name)
    return nil if taxon_name.nil?
    link_to(taxon_name_tag(taxon_name), taxon_name.metamorphosize).html_safe
  end

  def taxon_name_browse_link(taxon_name)
    return nil if taxon_name.nil?
    link_to(taxon_name_tag(taxon_name), browse_taxon_name_path(taxon_name.metamorphosize)).html_safe
  end

  def original_taxon_name_link(taxon_name)
    return nil if taxon_name.nil?
    link_to(original_taxon_name_tag(taxon_name).html_safe, browse_taxon_name_path(taxon_name))
  end

  def taxon_names_search_form
    render '/taxon_names/quick_search_form'
  end

  def taxon_name_for_select(taxon_name)
    taxon_name.name if taxon_name
  end

  # @taxon_name.parent.andand.display_name(:type => :for_select_list)
  def parent_taxon_name_for_select(taxon_name)
    taxon_name.parent ? taxon_name_for_select(taxon_name.parent) : nil
  end

  # TODO: Scope to code
  def taxon_name_rank_select_tag(taxon_name: TaxonName.new, code:  nil)
    select(:taxon_name, :rank_class, options_for_select(RANKS_SELECT_OPTIONS, selected: taxon_name.rank_string) ) 
  end

  def edit_original_combination_task_link(taxon_name)
    link_to('Edit original combination', edit_protonym_original_combination_task_path(taxon_name)) if GENUS_AND_SPECIES_RANK_NAMES.include?(taxon_name.rank_string)
  end

  # See #edit_object_path_string in  navigation_helper.rb
  def edit_taxon_name_path_string(taxon_name)
    if taxon_name.type == 'Protonym'
      'edit_taxon_name_path'
    elsif taxon_name.type == 'Combination'
      'edit_combination_path' 
    else
      nil 
    end
  end

  def edit_taxon_name_link(taxon_name)
    if taxon_name.type == 'Protonym'
      link_to(content_tag(:span, 'Edit', 'data-icon' => 'edit', 'class' => 'small-icon'), edit_taxon_name_path(taxon_name.metamorphosize), 'class' => 'navigation-item')
    else
      link_to(content_tag(:span, 'Edit', 'data-icon' => 'edit', 'class' => 'small-icon'), edit_combination_path(taxon_name), 'class' => 'navigation-item')
    end
  end 

  def rank_tag(taxon_name)
    case taxon_name.type
    when 'Protonym'
      if taxon_name.rank_class
        taxon_name.rank.downcase
      else
        content_tag(:em, 'ERROR')
      end
    when 'Combination'
      content_tag(:em, 'n/a')
    end
  end

  def ancestor_browse_taxon_name_link(taxon_name)
    text = 'Ancestor'
    taxon_name.ancestors.any? ? link_to(content_tag(:span, text, 'data-icon' => 'arrow-up', 'class' => 'small-icon'), browse_taxon_name_path(taxon_name.ancestors.first.metamorphosize), 'class' => 'navigation-item', 'data-arrow' => 'ancestor') : content_tag(:div, content_tag(:span, text, 'class' => 'small-icon', 'data-icon' => 'arrow-up'), 'class' => 'navigation-item disable')
  end

  def descendant_browse_taxon_name_link(taxon_name)
    text = 'Descendant'
    taxon_name.descendants.any? ? link_to(content_tag(:span, text, 'data-icon' => 'arrow-down', 'class' => 'small-icon'), browse_taxon_name_path(taxon_name.descendants.first.metamorphosize), 'class' => 'navigation-item', 'data-arrow' => 'descendant') : content_tag(:div, content_tag(:span, text, 'class' => 'small-icon', 'data-icon' => 'arrow-down'), 'class' => 'navigation-item disable') 
  end

  def next_sibling_browse_taxon_name_link(taxon_name)
    text = 'Next'
    link_object = nil

    if taxon_name.siblings.any?
      siblings = taxon_name.self_and_siblings.order(:cached).pluck(:id)
      s = siblings.index(taxon_name.id)
      link_object = TaxonName.find(siblings[ s + 1]) if s < siblings.length - 1
    end

    link_object.nil? ? content_tag(:div, content_tag(:span, text, 'class' => 'small-icon icon-right', 'data-icon' => 'arrow-right'), 'class' => 'navigation-item disable') : link_to(content_tag(:span, text, 'data-icon' => 'arrow-right', 'class' => 'small-icon icon-right'), browse_taxon_name_path(link_object.metamorphosize), 'class' => 'navigation-item', 'data-arrow' => 'next')
  end

  def previous_sibling_browse_taxon_name_link(taxon_name)
    text = 'Previous'
    link_object = nil
    if taxon_name.siblings.any?
      siblings = taxon_name.self_and_siblings.order(:cached).pluck(:id)
      s = siblings.index(taxon_name.id)
      link_object = TaxonName.find(siblings[ s - 1]) if s != 0 
    end

    link_object.nil? ? content_tag(:div, content_tag(:span, text, 'class' => 'small-icon', 'data-icon' => 'arrow-left'), 'class' => 'navigation-item disable') : link_to(content_tag(:span, text, 'data-icon' => 'arrow-left', 'class' => 'small-icon'), browse_taxon_name_path(link_object.metamorphosize), 'class' => 'navigation-item', 'data-arrow' => 'back')
  end

end
