json.current_collecting_event do
  json.id @collecting_event.id
  json.global_id @collecting_event.to_global_id.to_s
end

by_keyword = next_previous_by_inserted_keyword(@collecting_event)

json.previous_by do
  # Generics
  json.id @collecting_event.previous&.id
  json.identifier @collecting_event.previous_by_identifier&.id
  json.created_at nil
  json.user_created_at nil
  json.with_pinned_keyword by_keyword[0] 

  # Specific
  json.start_date nil
  json.verbatim_locality nil
  json.without_collectors nil
  json.without_collection_objects nil
  json.without_georeferences nil

end

json.next_by do
  json.id @collecting_event.next&.id
  json.identifier @collecting_event.next_by_identifier&.id
  json.created_at nil
  json.user_created_at nil
  json.with_pinned_keyword by_keyword[0] 

  # Specific
  json.start_date nil
  json.verbatim_locality nil
  json.without_collectors nil
  json.without_collection_objects nil
  json.without_georeferences nil
end


