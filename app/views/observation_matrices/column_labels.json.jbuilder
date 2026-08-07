json.merge! @observation_matrix.observation_matrix_columns.order(:position).collect{|r| {id: r.id, label: label_for_observation_matrix_column(r)}} 


