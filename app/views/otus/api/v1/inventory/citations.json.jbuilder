@catalog.citations_summary.each do |otu_id, entries|
  json.set! otu_id do
    json.array! entries do |entry|
      json.type entry[:type]
      json.source do
        s = entry[:source]
        json.id s.id
        json.cached s.cached
        json.author_year source_author_year_tag(s)
      end
      json.pages entry[:pages]
      json.is_original entry[:is_original]
      json.topics do
        json.array! entry[:topics] do |t|
          json.id t.id
          json.name t.name
          json.definition t.definition
          json.css_color t.css_color
        end
      end
    end
  end
end
