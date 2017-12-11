json.array!(@sequences) do |sequence|
  json.partial! 'attributes', sequence: sequence
end
