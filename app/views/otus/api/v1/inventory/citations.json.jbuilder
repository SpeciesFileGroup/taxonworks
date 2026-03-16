json.array! @catalog.citations_summary do |entry|
  json.type entry[:type]
  json.source do
    s = entry[:source]
    json.id s.id
    json.cached s.cached
    json.author_year source_author_year_tag(s)
  end
  json.topics do
    json.array! entry[:topics] do |t|
      json.id t.id
      json.name t.name
      json.definition t.definition
      json.css_color t.css_color
    end
  end
end
