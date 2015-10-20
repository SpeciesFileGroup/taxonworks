module OtuPageLayoutsHelper

  def otu_page_layout_tag(otu_page_layout)
    OtuPageLayoutsHelper.otu_page_layout_tag(otu_page_layout)
  end

  def otu_page_layout_select_tag
    select_tag(:otu_page_layout_id, options_from_collection_for_select(OtuPageLayout.all.where(project_id: $project_id), :id, :name), include_blank: true)
  end

end
