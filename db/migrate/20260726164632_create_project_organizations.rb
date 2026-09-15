class CreateProjectOrganizations < ActiveRecord::Migration[8.1]
  def change
    create_table :project_organizations do |t|
      t.references :organization, null: false, foreign_key: true, index: true
      t.references :project, null: false, foreign_key: true, index: true
      t.integer :created_by_id, null: false, index: true
      t.integer :updated_by_id, null: false, index: true

      t.timestamps
    end

    add_foreign_key :project_organizations, :users, column: :created_by_id
    add_foreign_key :project_organizations, :users, column: :updated_by_id

    add_index :project_organizations, [:project_id, :organization_id], unique: true
  end
end
