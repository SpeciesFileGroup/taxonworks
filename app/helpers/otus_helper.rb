module OtusHelper

  def self.otu_tag(otu)
    return nil if otu.nil?
    otu.name
  end

  def otu_tag(otu)
    OtusHelper.otu_tag(otu)
  end

  def otus_search_form
    render('/otus/quick_search_form')
  end

  def otus_link_list_tag(otus)
    otus.collect{|o| link_to(o.name, o)}.join(",")
  end

end
