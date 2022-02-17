json.merge! @observation_matrix.observation_matrix_rows.order(:position).collect{|r| {id: r.id, label: label_for_observation_matrix_row(r)}} 
