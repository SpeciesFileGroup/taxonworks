json.array! @images do |i|
  json.extract! i, :id, :image_file_fingerprint

  json.original short_url(i.image_file)
  json.thumb short_url(i.image_file.url(:thumb))
  json.medium short_url(i.image_file.url(:medium))

  if extend_response_with('depictions')
    json.depictions i.depictions do |d|
      json.extract! d, :caption, :figure_label, :depiction_object_type, :depiction_object_id
      json.label label_for_depiction(d)
    end
  end

  if extend_response_with('attribution')
    json.attribution do
      json.label label_for_attribution(i.attribution)
    end
  end

  if extend_response_with('source')
    json.partial! '/sources/api/v1/brief', source: i.source
  end

end
