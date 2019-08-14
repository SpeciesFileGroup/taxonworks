if object.respond_to?(:pinned?) && object.pinned?(sessions_current_user, sessions_current_project_id)
  json.pinboard_item do
    json.id object.pinboard_item_for(sessions_current_user).id
  end
end
