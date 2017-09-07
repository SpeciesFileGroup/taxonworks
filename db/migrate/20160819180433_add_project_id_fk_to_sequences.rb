class AddProjectIdFkToSequences < ActiveRecord::Migration[4.2]
  def change
    add_foreign_key :sequences, :projects, column: :project_id
  end
end
