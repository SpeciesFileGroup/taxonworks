class RenameIdentifierIndentifiableTypeToIdentifierType < ActiveRecord::Migration[4.2]
  def change
    rename_column :identifiers, :indentifiable_type, :identifiable_type 
  end
end
