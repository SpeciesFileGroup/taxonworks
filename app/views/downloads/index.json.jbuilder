json.array!(@downloads) do |download|
  json.partial! '/downloads/download', download: download
end
