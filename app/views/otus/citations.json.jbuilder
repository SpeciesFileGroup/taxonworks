json.array! @catalog.citations_summary.values do |data|
  json.otu do
    otu = data[:otu]
    json.id otu.id
    json.label label_for_otu(otu)
    json.global_id otu.to_global_id.to_s
  end

  json.citations do
    json.array! data[:citations] do |entry|
      json.id entry[:id]
      json.citation_object_type entry[:type]
      json.source do
        s = entry[:source]
        if s
          json.id s.id
          json.cached s.cached
          json.author_year source_author_year_tag(s)
          json.global_id s.to_global_id.to_s
          json.year s.year
        end
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
