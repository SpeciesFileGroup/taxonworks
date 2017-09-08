class MakeCitationCitationObjectIdAnInteger < ActiveRecord::Migration[4.2]
  def change
    remove_column :citations, :citation_object_id
    add_column :citations, :citation_object_id, :integer
    add_index :citations, :citation_object_id
  end
end
