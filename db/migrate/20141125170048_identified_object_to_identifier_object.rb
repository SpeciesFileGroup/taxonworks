class IdentifiedObjectToIdentifierObject < ActiveRecord::Migration
  def change
    remove_column(:identifiers, :identified_object_id)
    add_column(:identifiers, :identifier_object_id, :integer)
    add_index(:identifiers, :identifier_object_id)

    remove_column(:identifiers, :identified_object_type)
    add_column(:identifiers, :identifier_object_type, :string)
    add_index(:identifiers, :identifier_object_type)

    Identifier.connection.execute('ALTER TABLE identifiers ALTER COLUMN identifier_object_id SET NOT NULL;')
    Identifier.connection.execute('ALTER TABLE identifiers ALTER COLUMN identifier_object_type SET NOT NULL;')
  end
end
