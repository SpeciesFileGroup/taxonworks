module OtusHelper

  def otu_tag(otu)
    return nil if otu.nil?
    [  otu.name,
       Utilities::Strings.nil_wrap('[', full_taxon_name_tag(otu.taxon_name), ']')
    ].compact.join(' ').html_safe
  end

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
    otus.collect { |o| link_to(o.name, o) }.join(",")
  end

end
