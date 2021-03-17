json.current_collection_object do
  json.id @collection_object.id
  json.global_id @collection_object.to_global_id.to_s
end

by_keyword = next_previous_by_inserted_keyword(@collection_object)

json.previous_by do
  # Generics
  json.id @collection_object.previous&.id
  json.created_at @collection_object.previous_by_created_at&.id
  json.user_created_at @collection_object.previous_by_user_created_at(sessions_current_user_id)&.id
  json.with_pinned_keyword by_keyword[0] 
  json.identifier @collection_object.previous_by_identifier&.id

  # Specific, see app/helpers/collection_objects_helper.rb
  json.without_collecting_event @collection_object.base_navigation_previous.where(collecting_event: nil).first&.id 
  json.without_georeferences @collection_object.base_navigation_previous.left_outer_joins(:georeferences).where(georeferences: {id: nil}).first&.id 
  json.without_determiners @collection_object.base_navigation_previous.left_outer_joins(:roles).where(roles: {id: nil, type: 'TaxonDeterminer'}).first&.id
  end

json.next_by do
  json.id @collection_object.next&.id
  json.created_at @collection_object.next_by_created_at&.id 
  json.user_created_at @collection_object.next_by_user_created_at(sessions_current_user_id)&.id
  json.with_pinned_keyword by_keyword[1] 
  json.identifier @collection_object.next_by_identifier&.id

  json.without_collecting_event @collection_object.base_navigation_next.where(collecting_event: nil).first&.id 
  json.without_georeferences @collection_object.base_navigation_next.left_outer_joins(:georeferences).where(georeferences: {id: nil}).first&.id 
  json.without_determiners @collection_object.base_navigation_next.left_outer_joins(:roles).where(roles: {id: nil, type: 'TaxonDeterminer'}).first&.id
  end


