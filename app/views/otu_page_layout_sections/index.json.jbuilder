json.array!(@otu_page_layout_sections) do |otu_page_layout_section|
  json.extract! otu_page_layout_section, :id
  json.url otu_page_layout_section_url(otu_page_layout_section, format: :json)
end
