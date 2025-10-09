json.extract! user, :id, :name, :preferences, :created_by_id, :updated_by_id, :created_at, :updated_at

if extend_response_with('user_email_tag')
  json.label_html user_email_tag(user)
end

