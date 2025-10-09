if @download.persisted?
  json.status download_status(@download)

  json.download do
    json.partial! '/downloads/api/v1/attributes', download: @download
  end
else # has to be invalid at this point
  json.error_messages @download.errors.messages
end
