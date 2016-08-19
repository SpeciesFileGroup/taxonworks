class AddProjectIdFkToSequences < ActiveRecord::Migration
  def change
    add_foreign_key :sequences, :projects, column: :project_id
  end
end
