json.array! @collection_objects do |c|

  json.id c.id

  json.partial! '/shared/data/all/metadata', object: c # maybe not, since uses object_tag
  json.update_at c.updated_at

  json.dwc_attributes do
    c.set_dwc_occurrence # always rebuilds!!

    c.dwc_occurrence_attributes.each do |a, v|
      json.set!(a, v)
    end
  end

  json.container container_tag c.container
  json.biocuration c.biocuration_classes.pluck(:name).join(', ')

end
