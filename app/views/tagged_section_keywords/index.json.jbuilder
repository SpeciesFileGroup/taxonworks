json.array!(@tagged_section_keywords) do |tagged_section_keyword|
  json.extract! tagged_section_keyword, :id, :otu_page_layout_section_id, :position, :created_by_id, :updated_by_id, :project_id, :keyword_id
  json.url tagged_section_keyword_url(tagged_section_keyword, format: :json)
end
