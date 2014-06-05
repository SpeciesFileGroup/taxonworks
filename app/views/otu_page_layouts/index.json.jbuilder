json.array!(@otu_page_layouts) do |otu_page_layout|
  json.extract! otu_page_layout, :id
  json.url otu_page_layout_url(otu_page_layout, format: :json)
end
