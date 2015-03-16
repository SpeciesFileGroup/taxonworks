module OtusHelper

  ## ! sigh, we can't use content_tag in self. methods.  that will likely prevent this approach

  def self.otu_tag(otu)
    return nil if otu.nil?
    strs = []
    strs.push(otu.name) if !otu.name.nil?
    strs.push(otu.taxon_name.name) if otu.taxon_name_id
    if strs.size == 2 
     (strs[0] + " [#{strs[1]}]").html_safe
    else
      strs[0]
    end
  end

  def otu_tag(otu)
    OtusHelper.otu_tag(otu)
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

  def otus_batch_load_link
    if self.controller.respond_to?(:batch_load) 
      link_to('batch load', batch_load_otus_path) 
    else 
      content_tag(:span, 'batch load', class: 'disabled') 
    end
  end

end
