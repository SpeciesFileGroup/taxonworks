if params[:ancestors] != 'false'
  json.ancestors @taxon_name.ancestor_protonyms do |ancestor|
    json.extract! ancestor, :id, :cached_html, :cached_is_valid, :cached_author_year
  end
end

json.taxon_name do 
  json.extract! @taxon_name, :id, :cached_html, :cached_is_valid, :cached_author_year
  json.leaf_node @taxon_name.descendants.empty?
end

json.synonyms taxon_name_synonyms_list(@taxon_name).map { |syn| taxon_name_synonym_li(syn) }
json.children @taxon_name.children.order(:name).where(type: 'Protonym').sort_by{|a| [RANKS.index(a.rank_string), a.cached, a.cached_author_year || '']} do |child|
  json.extract! child, :id, :cached_html, :cached_is_valid, :cached_author_year, :name
  json.leaf_node child.descendants.empty?
end
