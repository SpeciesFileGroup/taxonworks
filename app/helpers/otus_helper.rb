module OtusHelper

  def otu_tag(otu)
    return nil if otu.nil?
    a = content_tag(:span, otu.name, class: :otu_tag_otu_name) if otu.name
    b = content_tag(:span, full_taxon_name_tag(otu.taxon_name).html_safe, class: :otu_tag_taxon_name) if otu.taxon_name_id
    content_tag(:span, [a,b].compact.join.html_safe, class: :otu_tag)
  end

  # @return [String]
  #    no HTML inside <input>
  def otu_autocomplete_selected_tag(otu)
    return nil if otu.nil? || (otu.new_record? && !otu.changed?)
    [otu.name, 
     Utilities::Strings.nil_wrap('[',taxon_name_autocomplete_selected_tag(otu.taxon_name), ']')
    ].compact.join(' ')
  end

  def otu_link(otu)
    return nil if otu.nil?
    link_to(otu_tag(otu).html_safe, otu)
  end

  def otus_search_form
    render('/otus/quick_search_form')
  end

  def otus_link_list_tag(otus)
    otus.collect { |o| link_to(o.name, o) }.join(',')
  end

  def otus_init(object)
    otu = object.metamorphosize
    content_tag(:div, '', 'data-taxon-name' => object_tag(otu), 'data-taxon-id' => otu.id, 'data-otu-init' => 'true')
  end

  def otus_radial(object)
    content_tag(:div, '', 'data-global-id' => object.to_global_id.to_s, 'data-otu-radial' => 'true')
  end

end
