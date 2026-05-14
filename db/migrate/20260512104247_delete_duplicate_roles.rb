class DeleteDuplicateRoles < ActiveRecord::Migration[8.1]
  # Roles have no associated data (no citations, notes, or other has_many
  # relationships), so duplicate records in the same group can be safely
  # deleted without any cascading concerns.
  #
  # A duplicate group is defined by the uniqueness constraint:
  #   (type, role_object_type, role_object_id, person_id)
  # We keep the lowest-id record in each group and delete the rest.
  def up
    transaction do
      result = execute(<<~SQL)
        DELETE FROM roles
        WHERE id IN (
          SELECT id FROM (
            SELECT id,
                   ROW_NUMBER() OVER (
                     PARTITION BY type, role_object_type, role_object_id, person_id
                     ORDER BY id
                   ) AS rn
            FROM roles
            WHERE person_id IS NOT NULL
          ) ranked
          WHERE rn > 1
        )
      SQL
      say "Deleted #{result.cmd_tuples} duplicate roles"
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
