module OtusHelper

  def otu_tag(otu)
    return nil if otu.nil?
    a = []
    a.push(content_tag(:span, otu.name, class: :otu_name))  if !otu.name.blank?

    if otu.taxon_name
      a.push "in" if !otu.name.blank?

      b = [ content_tag(:span, full_original_taxon_name_tag(otu.taxon_name), class: :otu_written) ]

      if !otu.taxon_name.is_valid?
        b.push 'now'
        b.push content_tag(:span, full_taxon_name_tag(otu.taxon_name.valid_taxon_name), class: :otu_current)
      end

      a.push content_tag(:span, b.join(' ').html_safe, class: :otu_taxon_name)
      a.push taxon_name_type_short_tag(otu.taxon_name).html_safe
    end
   
    content_tag(:span, a.flatten.compact.join(' ').html_safe, class: :otu_tag)
  end

  def otu_tag_elements(otu)
    return nil if otu.nil?
    [
      ( otu.name ? content_tag(:span, otu.name, class: :otu_tag_otu_name) : nil ),
      ( otu.taxon_name ? content_tag(:span, full_taxon_name_tag(otu.taxon_name).html_safe, class: :otu_tag_taxon_name, title: otu.taxon_name.id) : nil)
    ].compact
  end

  # @return [String]
  #    no HTML inside <input>
  def otu_autocomplete_selected_tag(otu)
    return nil if otu.nil? || (otu.new_record? && !otu.changed?)
    [otu.name,
     Utilities::Strings.nil_wrap('[',taxon_name_autocomplete_selected_tag(otu.taxon_name), ']')&.html_safe
    ].compact.join(' ')
  end

  def otu_link(otu)
    return nil if otu.nil?
    link_to(otu_tag_elements(otu).join(' ').html_safe, otu)
  end

  def label_for_otu(otu)
    return nil if otu.nil?
    [otu.name,
     label_for_taxon_name(otu.taxon_name)
    ].compact.join(': ')
  end

  def otus_search_form
    render('/otus/quick_search_form')
  end

  def otus_link_list_tag(otus)
    otus.collect { |o| link_to(o.name, o) }.join(',')
  end
 
  # Stub a smart link to browse OTUs
  # @param object [an instance of TaxonName or Otu]
  #   if TaxonName is provided JS UI will disambiguate if more options are possible
  def browse_otu_link(object)
    return nil if object.nil?
    otu = object.metamorphosize
    content_tag(:div, '', 'data-taxon-name' => object_tag(otu), 'data-redirect' => 'true', 'data-id' => otu.id, 'data-klass' => object.class.base_class.name.to_s, 'data-otu-button' => 'true')
  end

  def otus_radial_disambiguate(object)
    otu = object.metamorphosize
    content_tag(:div, '', 'data-taxon-name' => object_tag(otu), 'data-redirect' => 'false', 'data-id' => otu.id, 'data-klass' => object.class.base_class.name.to_s, 'data-otu-button' => 'true')
  end

  def otus_radial(object)
    content_tag(:div, '', 'data-global-id' => object.to_global_id.to_s, 'data-otu-radial' => 'true')
  end

  # @return [Array]
  #   of OTUs
  def next_otus(otu)
    if otu.taxon_name_id
      otu.taxon_name.next_sibling&.otus || []
    else
      Otu.where(project_id: otu.id).where('id > ?', otu.id).all
    end
  end

  def previous_otus(otu)
    if otu.taxon_name_id
      otu.taxon_name.previous_sibling&.otus || []
    else
      Otu.where(project_id: otu.id).where('id < ?', otu.id).all
    end
  end

  def parent_otus(otu)
    otu.taxon_name&.parent&.otus&.all || []
  end

  # See also otus#ancestor_otu_ids ?
  def parents_by_nomenclature(otu)
    above = [ ]
    if otu.taxon_name_id
      TaxonName.ancestors_of(otu.taxon_name)
        .select('taxon_names.*, taxon_name_hierarchies.generations')
        .that_is_valid.joins(:otus)
        .distinct
        .reorder('taxon_name_hierarchies.generations DESC, taxon_names.cached_valid_taxon_name_id').each do |t|
          above.push [t.cached, t.otus.to_a] # TODO: to_a vs. pluck
      end
    end
    above
  end

end
