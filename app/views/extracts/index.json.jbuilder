json.array!(@extracts) do |extract|
  json.partial! '/extracts/attributes', extract: extract
end
