class AllowNullObjectInLabel < ActiveRecord::Migration[5.2]
  def change
    change_column_null(:labels, :label_object_type, true)
    change_column_null(:labels, :label_object_id, true)

    change_column_default(:labels, :label_object_id, nil)
    change_column_default(:labels, :label_object_type, nil)
  end
end
