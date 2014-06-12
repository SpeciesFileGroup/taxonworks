json.array!(@otu_page_layout_sections) do |otu_page_layout_section|
  json.extract! otu_page_layout_section, :id, :otu_page_layout_id, :type, :position, :topic_id, :dynamic_content_class, :created_by_id, :updated_by_id, :project_id
  json.url otu_page_layout_section_url(otu_page_layout_section, format: :json)
end
