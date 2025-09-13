json.array!(@gazetteers) do |gazetteer|
  json.partial! 'attributes',  gazetteer:
end
