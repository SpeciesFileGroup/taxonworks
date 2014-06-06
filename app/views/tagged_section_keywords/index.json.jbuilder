json.array!(@tagged_section_keywords) do |tagged_section_keyword|
  json.extract! tagged_section_keyword, :id
  json.url tagged_section_keyword_url(tagged_section_keyword, format: :json)
end
