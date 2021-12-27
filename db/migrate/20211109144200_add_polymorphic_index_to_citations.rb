class AddPolymorphicIndexToCitations < ActiveRecord::Migration[6.1]
  def change
    add_index :citations, [:citation_object_id, :citation_object_type]
  end
end
