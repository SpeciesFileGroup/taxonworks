json.array! @data.keys do |k|
  json.dwc_occurrence_id k
  json.images do
    json.array! @data[k] do |i|
      json.id i.id
      json.partial! '/images/api/v1/attributes', image: i
    end
  end
end
