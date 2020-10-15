json.array!(@downloads) do |download|
  json.partial! '/downloads/api/v1/attributes', download: download
end
