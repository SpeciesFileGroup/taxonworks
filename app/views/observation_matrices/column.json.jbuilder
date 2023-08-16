json.id @observation_matrix_column.id

json.descriptor do
  json.partial! "/descriptors/attributes", descriptor: @observation_matrix_column.descriptor
end

json.observation_matrix do
  json.partial! "/observation_matrices/attributes", observation_matrix: @observation_matrix_column.observation_matrix
end

if a = @observation_matrix_column.next_column
  json.next_column do
    json.partial! "/observation_matrix_columns/attributes", observation_matrix_column:  a
  end
end

if a = @observation_matrix_column.previous_column
  json.previous_column do
    json.partial! "/observation_matrix_columns/attributes", observation_matrix_column: a
  end
end

json.rows do |rows|
  rows.array!(@observation_matrix_column.observation_matrix.observation_matrix_rows.order(:position)) do |r|
    json.id r.id
    # no row_id
    json.object_tag object_tag(r.observation_object)
    json.observation_object_type r.observation_object_type
    json.observation_object_id r.observation_object_id
    json.observation_object_global_id r.observation_object.to_global_id.to_s
    json.position r.position
  end
end

=begin
json.otus do |otus|
  otus.array!(@observation_matrix_column.observation_matrix.otus.select('otus.*, observation_matrix_rows.id AS row_id').includes(:observation_matrix_rows).order('observation_matrix_rows.position ASC')) do |otu|
    otus.partial! '/otus/attributes', otu: otu
    json.row_id otu.row_id
  end
end

json.collection_objects do |collection_objects|
  collection_objects.array!(@observation_matrix_column.observation_matrix.collection_objects.select('collection_objects.*, observation_matrix_rows.id AS row_id').includes(:observation_matrix_rows).order('observation_matrix_rows.position ASC')) do |collection_object|
    collection_objects.partial! '/collection_objects/attributes', collection_object: collection_object
    json.row_id collection_object.row_id
  end
end
=end