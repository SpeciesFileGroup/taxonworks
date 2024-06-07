json.array!(@gazeteers) do |gazeteer|
  json.partial! 'attributes',  gazeteer:
end
