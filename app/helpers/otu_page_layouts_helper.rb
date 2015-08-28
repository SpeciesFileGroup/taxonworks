module OtuPageLayoutsHelper
  def self.otu_page_layout_tag(otu_page_layout)
    return nil if otu_page_layout.nil?
    otu_page_layout.name
  end

  def otu_page_layout_tag(otu_page_layout)
    OtuPageLayoutsHelper.otu_page_layout_tag(otu_page_layout)
  end


end
