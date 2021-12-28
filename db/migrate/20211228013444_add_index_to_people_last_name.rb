class AddIndexToPeopleLastName < ActiveRecord::Migration[6.1]
  def change
    add_index :people, :last_name
    add_index :people, :cached
  end
end
