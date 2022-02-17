json.merge! @observation_matrix.observation_matrix_columns.order(:position)
.inject({}){|hsh, r| hsh[r.id] = {r.id => {label: label_for_observation_matrix_column(r), position: r.position}}; hsh} 


