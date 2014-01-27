class StandardizeIdentifiableToIdentifiedObject < ActiveRecord::Migration
  def change
    rename_column :identifiers, :identifiable_id, :identified_object_id
    rename_column :identifiers, :identifiable_type, :identified_object_type
  end
end
