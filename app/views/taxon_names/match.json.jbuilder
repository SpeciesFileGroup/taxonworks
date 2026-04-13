json.array! @result do |r|

  json.scientific_name r[:scientific_name]
  json.taxon_name_id r[:taxon_name_id]

  json.taxon_name do
    if r[:taxon_name]
      json.extract! r[:taxon_name],
        :id,
        :cached,
        :cached_html,
        :cached_author_year,
        :cached_valid_taxon_name_id,
        :name,
        :rank_class,
        :type

      json.global_id r[:taxon_name].to_global_id.to_s
      json.object_label label_for_taxon_name(r[:taxon_name])
    end
  end

  json.otus r[:otus] do |o|
    json.extract! o, :id, :name, :taxon_name_id
    json.object_label label_for_otu(o)
  end

  json.ambiguous r[:ambiguous]
  json.matched r[:matched]
end
