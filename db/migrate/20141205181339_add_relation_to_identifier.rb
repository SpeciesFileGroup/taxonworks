class AddRelationToIdentifier < ActiveRecord::Migration
  def change
    add_column :identifiers, :relation, :string
  end
end
