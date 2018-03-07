json.array!(@users) do |user|
  json.extract! user, :id, :email, :created_by_id, :updated_by_id
  json.url user_url(user, format: :json)
end
