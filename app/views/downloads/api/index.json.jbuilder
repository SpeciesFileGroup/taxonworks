json.array!(@downloads) do |download|
  json.partial! '/downloads/api/attributes', download: download
end
