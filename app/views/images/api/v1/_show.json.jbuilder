json.partial! '/images/api/v1/attributes', image: image

json.original short_url(image.image_file)
json.thumb short_url(image.image_file.url(:thumb))
json.medium short_url(image.image_file.url(:medium))

# This can be confused. It will list all depictions that use this image, regardless of whether they are particular to the scope of some queries.
if extend_response_with('depictions')
  json.depictions image.depictions do |d|
    # TOOD: make a /brief. Consider using global_id
    json.extract! d, :figure_label, :caption, :depiction_object_type, :depiction_object_id
    json.label label_for_depiction(d)
  end
end

if extend_response_with('attribution')
  json.attribution do
    if image.attribution
      json.label label_for_attribution(image.attribution)
      json.id image.attribution.id
      # json.partial! '/attributions/api/v1/attributes', attribution: image.attribution, extensions: false
    end
  end
end

if extend_response_with('source')
  if image.source
    json.partial! '/sources/api/v1/brief', source: image.source
  end
end
