json.extract! @taxon_name, :id, :parent_id, :name
json.is_valid @taxon_name.cached_is_valid
json.full_name label_for_taxon_name(@taxon_name)
json.full_name_tag full_taxon_name_tag(@taxon_name)

json.nomenclatural_code @taxon_name.nomenclatural_code
json.short_status taxon_name_short_status_label(@taxon_name)
json.status taxon_name_status_label(@taxon_name)
json.rank @taxon_name.rank
json.rank_string @taxon_name.rank_string
json.author @taxon_name.author_string
json.year @taxon_name.cached_nomenclature_date&.year
json.pages @taxon_name.origin_citation&.pages
json.original_citation @taxon_name.source&.cached

json.timeline do
  json.array! @data[:timeline]
end

json.sources do
  json.array! @data[:sources].each do |s|
    json.cached s.cached
    json.url s.url
  end
end

json.stats taxon_name_inventory_stats(@taxon_name)

# !! Comes from Catalog/Data.  Likely should make this calculable on demand.
json.distribution @data[:distribution]

json.repositories do
  json.array! @data[:repositories]
end
