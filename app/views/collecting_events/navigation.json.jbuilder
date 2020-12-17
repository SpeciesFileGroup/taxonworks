json.current_collecting_event do
  json.id @collecting_event.id
  json.global_id @collecting_event.to_global_id.to_s
end

by_keyword = next_previous_by_inserted_keyword(@collecting_event)

json.previous_by do
  # Generics
  json.id @collecting_event.previous&.id
  json.created_at @collecting_event.previous_by_created_at&.id
  json.user_created_at @collecting_event.previous_by_user_created_at(sessions_current_user_id)&.id
  json.with_pinned_keyword by_keyword[0] 
  json.identifier @collecting_event.previous_by_identifier&.id

  # Specific, see app/helpers/collecting_events_helper.rb
  json.start_date nil
  json.verbatim_locality nil
  json.without_collectors @collecting_event.base_navigation_previous.left_outer_joins(:roles).where(roles: {id: nil}).first&.id
  json.without_collection_objects @collecting_event.base_navigation_previous.left_outer_joins(:collection_objects).where(collection_objects: {id: nil}).first&.id 
  json.without_georeferences @collecting_event.base_navigation_previous.left_outer_joins(:georeferences).where(georeferences: {id: nil}).first&.id 
end

json.next_by do
  json.id @collecting_event.next&.id
  json.created_at @collecting_event.next_by_created_at&.id 
  json.user_created_at @collecting_event.next_by_user_created_at(sessions_current_user_id)&.id
  json.with_pinned_keyword by_keyword[1] 
  json.identifier @collecting_event.next_by_identifier&.id

  # Specific
  json.start_date nil
  json.verbatim_locality nil
  json.without_collectors @collecting_event.base_navigation_next.left_outer_joins(:roles).where(roles: {id: nil}).first&.id
  json.without_collection_objects @collecting_event.base_navigation_next.left_outer_joins(:collection_objects).where(collection_objects: {id: nil}).first&.id 
  json.without_georeferences @collecting_event.base_navigation_next.left_outer_joins(:georeferences).where(georeferences: {id: nil}).first&.id 
end


