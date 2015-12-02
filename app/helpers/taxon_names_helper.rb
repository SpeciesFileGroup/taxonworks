module TaxonNamesHelper

  def taxon_name_tag(taxon_name)
    return nil if taxon_name.nil?
    # TODO: fix generation of empty string cached author year
    #taxon_name.cached_html ? [taxon_name.cached_html, taxon_name.cached_author_year].join(' ').strip.html_safe : taxon_name.name
    taxon_name.cached_html.strip.html_safe || taxon_name.name
  end

  def original_taxon_name_tag(taxon_name)
    return nil if taxon_name.nil?
    taxon_name.cached_original_combination.nil? ? taxon_name.cached_html.strip.html_safe || taxon_name.name : taxon_name.cached_original_combination.strip.html_safe
  end

  def cached_author_year_tag(taxon_name)
    taxon_name.cached_author_year ? ' ' +  taxon_name.cached_author_year.strip.html_safe : ''
  end

  def taxon_name_autocomplete_selected_tag(taxon_name)
    return nil if taxon_name.nil?
    taxon_name.cached
  end

  def taxon_name_link(taxon_name)
    return nil if taxon_name.nil?
    link_to(taxon_name_tag(taxon_name).html_safe, browse_taxon_name_path(taxon_name))
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
        if @taxon_name.rank_class
          @taxon_name.rank.downcase
        else
          content_tag(:em, 'ERROR')
        end
      when 'Combination'
          content_tag(:em, 'n/a')
    end
  end

  # A previous record link.
  def previous_link_taxon_name_browse(taxon_name)
    text = 'Previous'
    if taxon_name.respond_to?(:project_id)
      link_object = Protonym.order(lft: :desc).with_project_id(taxon_name.project_id).where(['lft < ?', taxon_name.lft]).limit(1).first
    else
      link_object = Protonym.order(lft: :desc).where(['lft < ?', taxon_name.lft]).limit(1).first
    end
    link_object.nil? ? text : link_to(text, browse_taxon_name_path(link_object.metamorphosize))
  end

  # A next record link.
  def next_link_taxon_name_browse(taxon_name)
    text = 'Next'
    if taxon_name.respond_to?(:project_id)
      link_object = Protonym.order(lft: :asc).with_project_id(taxon_name.project_id).where(['lft > ?', taxon_name.lft]).limit(1).first
    else
      link_object = Protonym.order(lft: :asc).where(['lft > ?', taxon_name.lft]).limit(1).first
    end
    link_object.nil? ? text : link_to(text, browse_taxon_name_path(link_object.metamorphosize))
  end
end
