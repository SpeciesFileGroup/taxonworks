json.array! @data.citations_with_names.keys.sort{|a,b| a.cached <=> b.cached}.each do |s|
  json.source do
    json.id s.id
    json.name s.cached
    json.short_name source_author_year_tag(s)
  end
  json.names @data.citations_with_names[s].collect{|n| full_taxon_name_tag(n)}.sort
end