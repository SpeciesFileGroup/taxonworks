json.array!(@confidences) do |confidence|
  json.partial! '/confidences/attributes', confidence: confidence
end
