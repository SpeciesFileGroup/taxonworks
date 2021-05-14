json.success true

json.open_projects do
  json.array! open_api_projects.pluck(:api_access_token, :name) do |token, name|
    json.set! token, name
  end
end
