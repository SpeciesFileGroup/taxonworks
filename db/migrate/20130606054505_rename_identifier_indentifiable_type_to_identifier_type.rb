class RenameIdentifierIndentifiableTypeToIdentifierType < ActiveRecord::Migration
  def change
    rename_column :identifiers, :indentifiable_type, :identifiable_type 
  end
end
