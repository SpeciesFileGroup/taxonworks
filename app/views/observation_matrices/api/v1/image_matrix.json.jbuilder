# Build out the json response as needed

json.observation_matrix_id @key.observation_matrix_id
json.observation_matrix_citation @key.observation_matrix_citation
json.descriptor_available_languages @key.descriptor_available_languages
json.language_id @key.language_id
json.language_to_use @key.language_to_use
json.keyword_ids @key.keyword_ids
json.descriptor_available_keywords @key.descriptor_available_keywords
json.row_filter @key.row_filter
json.row_id_filter_array @key.row_id_filter_array
json.otu_filter @key.otu_filter
json.otu_id_filter_array @key.otu_id_filter_array
json.identified_to_rank @key.identified_to_rank

json.pagination @key, :pagination_page, :pagination_per_page, :pagination_total, :pagination_total_pages, :pagination_next_page, :pagination_previous_page

json.list_of_descriptors @key.list_of_descriptors.sort_by {|k, v| v[:index]}.map { |k, v| v }
json.image_hash @key.image_hash

json.depiction_matrix (@key.depiction_matrix) do |d, v|
  json.label label_for(v[:object])
  json.depictions (v[:depictions]) do |depiction|
    json.array! depiction do |d|
      json.extract! d, :id, :depiction_object_id, :depiction_object_type, :image_id, :caption, :figure_label
    end
  end
end

if @key.observation_matrix
  json.observation_matrix @key.observation_matrix
end