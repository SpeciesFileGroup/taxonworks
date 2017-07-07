json.array!(@observations) do |observation|
  json.partial! '/observations/attributes', observation: observation
end
