json.download do
  json.partial! '/downloads/api/v1/attributes', download: @download
end

json.status do 
  json.status download_status(@download)
end
