module OtusHelper

  def otu_tag(otu)
    return nil if otu.nil?
    strs = []
    strs.push(otu.name) if !otu.name.nil?
    strs.push(taxon_name_tag(otu.taxon_name)) if otu.taxon_name_id
    if strs.size == 2 
      (strs[0] + " [#{strs[1]}]").html_safe
    else
      strs[0]
    end
  end

  def otu_autocomplete_selected_tag(otu)
    return nil if otu.nil? || (otu.new_record? && !otu.changed?)
    [otu.name, (otu.taxon_name.nil? ? nil : "[#{otu.taxon_name.cached}]")].compact.join(" ")
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
