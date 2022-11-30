json.partial! 'attributes', user: @user

if extend_response_with('projects')
  json.projects do
    json.partial! '/projects/attributes', collection: @user.projects, as: :project
  end
end
