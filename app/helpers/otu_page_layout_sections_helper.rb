module OtuPageLayoutSectionsHelper

  def otu_page_layout_section_tag(otu_page_layout_section)
    return nil if otu_page_layout_section.nil?
    otu_page_layout_section.otu_page_layout.name + ": " + otu_page_layout_section.topic.name
  end

end
