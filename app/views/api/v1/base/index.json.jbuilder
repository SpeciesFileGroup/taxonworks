json.success true

json.open_projects do
  json.array! Project.where.not(api_access_token: nil).pluck(:api_access_token, :name) do |token, name|
    json.set! token, name
  end
end
