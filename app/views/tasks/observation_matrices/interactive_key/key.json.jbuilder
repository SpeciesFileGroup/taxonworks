# Build out the json response as needed

json.observation_matrix_id @key.observation_matrix_id
json.project_id @key.project_id
json.observation_matrix @key.observation_matrix
json.descriptor_available_languages @key.descriptor_available_languages
json.language_id @key.language_id
json.language_to_use @key.language_to_use
json.keyword_ids @key.keyword_ids
json.descriptor_available_keywords @key.descriptor_available_keywords
json.descriptors_with_filter @key.descriptors_with_filter
json.row_filter @key.row_filter
json.rows_with_filter @key.rows_with_filter
json.sorting @key.sorting
json.error_tolerance @key.error_tolerance
json.eliminate_unknown @key.eliminate_unknown
json.identified_to_rank @key.identified_to_rank
json.selected_descriptors@key.selected_descriptors
json.selected_descriptors_hash @key.selected_descriptors_hash
# json.remaining @key.remaining
#json.eliminated @key.eliminated
json.list_of_descriptors @key.list_of_descriptors

json.remaining do
  json.array!(@key.remaining) do |object|
    json.partial! '/shared/data/all/metadata', object: object
    json.merge! object.attributes
  end
end

json.eliminated do
  json.array!(@key.eliminated) do |object|
    json.partial! '/shared/data/all/metadata', object: object
    json.merge! object.attributes
  end
end