class AddRelationToIdentifier < ActiveRecord::Migration[4.2]
  def change
    add_column :identifiers, :relation, :string
  end
end
