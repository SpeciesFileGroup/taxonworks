module TaxonNamesHelper

  def taxon_name_tag(taxon_name)
    return nil if taxon_name.nil?
    return taxon_name.name if taxon_name.new_record?
    # TODO: fix generation of empty string cached author year
    #taxon_name.cached_html ? [taxon_name.cached_html, taxon_name.cached_author_year].join(' ').strip.html_safe : taxon_name.name
    taxon_name.cached_html.strip.html_safe || taxon_name.name
  end

  def original_taxon_name_tag(taxon_name)
    return nil if taxon_name.nil?
    taxon_name.cached_original_combination.nil? ? taxon_name.cached_html.strip.html_safe || taxon_name.name : taxon_name.cached_original_combination.strip.html_safe
  end

  def cached_author_year_tag(taxon_name)
    taxon_name.cached_author_year ? ' ' +  taxon_name.cached_author_year.strip.html_safe : nil
  end

  def full_taxon_name_tag(taxon_name)
    return nil if taxon_name.nil?
    [taxon_name_tag(taxon_name), cached_author_year_tag(taxon_name)].compact.join(" ").html_safe
  end

  def full_original_taxon_name_tag(taxon_name)
    return nil if taxon_name.nil?
    [original_taxon_name_tag(taxon_name), cached_author_year_tag(taxon_name)].compact.join(" ").html_safe
  end

  def nomenclature_line_tag(nomenclature_catalog_item)
    i = nomenclature_catalog_item
    c = i.citation
    content_tag(:li) do  
      if i.cited?
        case i.cited_class
        when 'TaxonName'
          taxon_name_nomenclature_line_tag(c) 
        when 'TaxonNameRelationship'
          [taxon_name_relationship_for_object_tag(c.annotated_object),  c.citation_topics.collect{|t| t.topic.name}.join(", "), "REL" ].compact.join(" ").html_safe    
        else 
          "strange, a citation class that is not handled"
        end
      else
        case i.cited_class
        when 'TaxonName'
          [ full_original_taxon_name_tag(i.object), type_taxon_name_relationship_tag(i.object.type_taxon_name_relationship) ].compact.join(". ").html_safe
        when 'TaxonNameRelationship'
          [ full_original_taxon_name_tag(i.object.subject_taxon_name), taxon_name_statuses_tag(i.object.subject_taxon_name)].join(" ").html_safe 
        else 
          i.cited_class
        end
      end
    end
  end

  def taxon_name_statuses_tag(taxon_name)
    return nil if taxon_name.taxon_name_statuses.empty?
    ('(' + taxon_name.taxon_name_statuses.join(', ') + ')').html_safe 
  end


  def taxon_name_nomenclature_line_tag(citation)
    taxon_name = citation.annotated_object

    [ original_taxon_name_tag(taxon_name),
      (citation.is_original? ? nil : "."), 
      (citation.is_original? ? cached_author_year_tag(taxon_name) : "AUTHOR OF CITATION FROM BIBTEX" ), 
      (citation.try(:pages) ? ": #{citation.pages}" : nil),
      ".",
      citation.citation_topics.collect{|t| t.topic.name}.join(", "),

    ].compact.join("").html_safe

  end


  # @return a complete list of citations pertinent to the taxonomic history
  def full_citations(taxon_name)
    data = NomenclatureCatalogEntry.new

    data.items <<  NomenclatureCatalogEntry::NomenclatureCatalogItem.new(taxon_name, taxon_name.nomenclature_date)

    TaxonNameRelationship.where_object_is_taxon_name(taxon_name).with_type_array(TAXON_NAME_RELATIONSHIP_NAMES_INVALID).each do |r|
      r.citations.each do |i|
        data.items << NomenclatureCatalogEntry::NomenclatureCatalogItem.new(i, i.subject_taxon_name.nomenclature_date)
      end
    end

    TaxonNameRelationship.where_object_is_taxon_name(taxon_name).with_type_array(TAXON_NAME_RELATIONSHIP_NAMES_INVALID).without_citations.each do |r|
      data.items << NomenclatureCatalogEntry::NomenclatureCatalogItem.new(r, r.subject_taxon_name.nomenclature_date)
    end

    # must be inverted
    TaxonNameRelationship.where_subject_is_taxon_name(taxon_name).with_type_array(STATUS_TAXON_NAME_RELATIONSHIP_NAMES).each do |r|
      data.items << NomenclatureCatalogEntry::NomenclatureCatalogItem.new(r, r.subject_taxon_name.nomenclature_date)
    end

    # !?
    # list.push(@taxon_name) unless @taxon_name.cached_original_combination.nil? 

    Combination.with_cached_valid_taxon_name_id(@taxon_name).not_self(@taxon_name).each do |c|
      data.items << NomenclatureCatalogEntry::NomenclatureCatalogItem.new(c, c.nomenclature_date)
    end

    data
  end

  def latinization_tag(taxon_name)
    list = TaxonNameClassification.where_taxon_name(@taxon_name).with_type_array(LATINIZED_TAXON_NAME_CLASSIFICATION_NAMES)
    if list.any?
      content_tag(:h3, 'Latinization') +
        list.collect{|c|
        content_tag(:span, c.classification_label) 
      }.html_safe 
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
      link_to 'Edit', edit_taxon_name_path(taxon_name.metamorphosize)
    else
      link_to 'Edit', edit_combination_path(taxon_name)
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
    taxon_name.ancestors.any? ? link_to(text, browse_taxon_name_path(taxon_name.ancestors.first.metamorphosize)) : text 
  end

  def descendant_browse_taxon_name_link(taxon_name)
    text = 'Descendant'
    taxon_name.descendants.any? ? link_to(text, browse_taxon_name_path(taxon_name.descendants.first.metamorphosize)) : text 
  end

  def next_sibling_browse_taxon_name_link(taxon_name)
    text = 'Next'
    link_object = nil

    if taxon_name.siblings.any?
      siblings = taxon_name.self_and_siblings.order(:cached).pluck(:id)
      s = siblings.index(taxon_name.id)
      link_object = TaxonName.find(siblings[ s + 1]) if s < siblings.length - 1
    end

    link_object.nil? ? text : link_to(text, browse_taxon_name_path(link_object.metamorphosize))
  end

  def previous_sibling_browse_taxon_name_link(taxon_name)
    text = 'Previous'
    link_object = nil
    if taxon_name.siblings.any?
      siblings = taxon_name.self_and_siblings.order(:cached).pluck(:id)
      s = siblings.index(taxon_name.id)
      link_object = TaxonName.find(siblings[ s - 1]) if s != 0 
    end

    link_object.nil? ? text : link_to(text, browse_taxon_name_path(link_object.metamorphosize))
  end

end
