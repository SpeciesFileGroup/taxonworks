json.array!(@observations) do |observation|
  json.partial! '/observations/api/attributes', observation: observation
end
