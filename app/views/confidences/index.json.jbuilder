json.array!(@confidences) do |confidence|
  json.partial! 'attributes', confidence: confidence
end
