json.array! @collection_objects do |c|

  json.id c.id

  json.partial! '/shared/data/all/metadata', object: c # maybe not, since uses object_tag
  json.updated_at time_ago_in_words(c.updated_at)
  json.updater c.updater.name
  json.container container_tag c.container
  json.identifier_from_container collection_object_visualized_identifier(c)&.first == :container ? true : false
  json.biocuration c.biocuration_classes.pluck(:name).join(', ')

  json.dwc_attributes do
    c.set_dwc_occurrence # always rebuilds!! (used in recent lists)
    c.dwc_occurrence_attributes.each do |a, v|
      json.set!(a, v)
    end
  end

end
