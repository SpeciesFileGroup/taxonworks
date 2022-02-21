class AddIndexOnSomeUpdatedAtFields < ActiveRecord::Migration[6.1]
  def change
    add_index :biological_associations, :updated_at
    add_index :contents, :updated_at
    add_index :data_attributes, :updated_at
    add_index :loans, :updated_at
    add_index :observations, :updated_at
    add_index :otus, :updated_at
    add_index :sequences, :updated_at
  end
end
