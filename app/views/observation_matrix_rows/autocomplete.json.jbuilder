json.array! @observation_matrix_rows do |t|
  json.id t.id
  json.position t.position
  json.observation_matrix_id t.observation_matrix_id
  json.observation_matrix_label observation_matrix_label(t.observation_matrix)
  json.object_type t.class.base_class.to_s.tableize
  json.label label_for(t.observation_object)
  json.observation_object_global_id t.observation_object_global_id

  json.response_values do 
    if params[:method]
      json.set! params[:method], t.id
    end
  end 
end

