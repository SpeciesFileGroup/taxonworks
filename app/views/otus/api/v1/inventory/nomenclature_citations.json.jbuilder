json.array! @data.citations_with_names.keys.sort.each do |k|
  json.citation k
  json.names @data.citations_with_names[k].collect{|n| full_taxon_name_tag(n)}.sort
end