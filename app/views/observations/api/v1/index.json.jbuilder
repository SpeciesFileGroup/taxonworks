json.array!(@observations) do |observation|
  json.partial! '/observations/api/v1/attributes', observation: observation
end
