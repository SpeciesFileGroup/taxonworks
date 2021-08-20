# Build out the json response as needed

json.observation_matrix_id @description.observation_matrix_id
json.generated_description @description.generated_description
json.generated_diagnosis @description.generated_diagnosis
json.observation_matrix_row_id @description.observation_matrix_row_id

json.similar_objects (@description.similar_objects) do |r|
  json.extract! r, :similarities
  if r[:collection_object_id].present?
    json.collection_object_tag collection_object_tag(CollectionObject.find(r[:collection_object_id]))
    json.collection_object_id r[:collection_object_id]
  end
  if r[:otu_id].present?
    json.otu_id r[:otu_id]
    json.otu_label otu_tag(Otu.find(r[:otu_id]))
  end
  
end