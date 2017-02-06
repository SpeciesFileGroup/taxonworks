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
  #    no HTML inside <input>
  def taxon_name_autocomplete_selected_tag(taxon_name)
    [taxon_name.cached, taxon_name.cached_author_year].compact.join(' ') 
  end

  # @return [String]
  #   the taxon name in original combination, without author year, with HTML
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
    [
      original_taxon_name_tag(taxon_name), 
      history_author_year_tag(taxon_name)
    ].compact.join(" ").html_safe
  end

  def original_author_year(taxon_name)
    return nil if taxon_name.nil? || taxon_name.cached_author_year.nil?
    taxon_name.cached_author_year.gsub(/^\(|\)$/, '')
  end

  def current_author_year(taxon_name)
    return nil if taxon_name.nil? || taxon_name.cached_author_year.nil?
    taxon_name.cached_author_year
  end

  def taxon_name_short_status(taxon_name)
    if taxon_name.unavailable_or_invalid?
      content_tag(:span, 'This name is not valid/accepted.', class: :brief_status, data: {icon: :attention}) 
    else
      content_tag(:span, 'This name is valid/accepted.', class: :brief_status, data: {icon: :ok }) 
    end
  end

  def taxon_name_gender_sentence_tag(taxon_name)
    return nil if taxon_name.nil?
    "The name is #{taxon_name.gender_name}." if taxon_name.gender_name
  end

  def cached_classified_as_tag(taxon_name)
    taxon_name.cached_classified_as ? taxon_name.cached_classified_as.strip.html_safe : ''
  end

  def taxon_name_autocomplete_selected_tag(taxon_name)
    return nil if taxon_name.nil?
    taxon_name.cached
  end

  def taxon_name_latinization_tag(taxon_name)
    list = taxon_name.taxon_name_classifications.with_type_array(LATINIZED_TAXON_NAME_CLASSIFICATION_NAMES).map(&:classification_label)
    content_tag(:span,  "The word \"#{taxon_name.name}\" has the following Latin-based classifications: #{list.to_sentence}.", class: 'history__latinized_classifications') if list.any?
  end

  def taxon_name_link(taxon_name)
    return nil if taxon_name.nil?
    link_to(taxon_name_tag(taxon_name), taxon_name.metamorphosize).html_safe
  end

  def taxon_name_browse_link(taxon_name)
    return nil if taxon_name.nil?
    [ link_to(taxon_name_tag(taxon_name), browse_nomenclature_task_path(taxon_name.metamorphosize)).html_safe,  taxon_name.cached_author_year].compact.join(' ').html_safe
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

  def ancestor_browse_taxon_name_link(taxon_name, path = :browse_nomenclature_task_path)
    text = 'Up'
    taxon_name.ancestors.any? ? 
      link_to(content_tag(:span, text, data: {icon: 'arrow-up'}, class: 'small-icon'), send(path,taxon_name.ancestors.first.metamorphosize), class: 'navigation-item', data: {arrow: 'ancestor'}) :
      content_tag(:div, content_tag(:span, text, class: 'small-icon', data: {icon: 'arrow-up'}), class: 'navigation-item disable')
  end

  def descendant_browse_taxon_name_link(taxon_name, path = :browse_nomenclature_task_path)
    text = 'Down'
    taxon_name.descendants.any? ? 
      link_to(content_tag(:span, text, data: {icon: 'arrow-down'}, class: 'small-icon'), send(path, taxon_name.descendants.first.metamorphosize), class: 'navigation-item', data: {arrow: 'descendant'}) : 
      content_tag(:div, content_tag(:span, text, class: 'small-icon', data: {icon: 'arrow-down'}), class: 'navigation-item disable') 
  end

  def next_sibling_browse_taxon_name_link(taxon_name, path = :browse_nomenclature_task_path)
    text = 'Next'
    link_object = taxon_name.next_sibling

    link_object.nil? ? 
      content_tag(:div, content_tag(:span, text, class: 'small-icon icon-right', data: {icon: 'arrow-right'}), class:  'navigation-item disable') : 
      link_to(content_tag(:span, text, data: {icon: 'arrow-right'}, class: 'small-icon icon-right'), send(path, link_object.metamorphosize), class: 'navigation-item', data: {arrow: 'next'})
  end

  def previous_sibling_browse_taxon_name_link(taxon_name, path = :browse_nomenclature_task_path)
    text = 'Previous'
    link_object = taxon_name.previous_sibling

    link_object.nil? ? 
      content_tag(:div, content_tag(:span, text, class: 'small-icon', data: {icon: 'arrow-left'}), class: 'navigation-item disable') : 
      link_to(content_tag(:span, text, data: {icon: 'arrow-left'}, class: 'small-icon'), send(path, link_object.metamorphosize), class: 'navigation-item', data: {arrow: 'back'})
  end


end
