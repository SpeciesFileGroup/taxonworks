json.array! @results do |result|
  json.extract! result, :identifier, :collection_object_id, :ambiguous, :matched
  json.global_id @global_ids[result[:collection_object_id]]
end
