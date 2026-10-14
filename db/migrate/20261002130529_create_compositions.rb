class CreateCompositions < ActiveRecord::Migration[8.1]
  def change
    create_table :compositions do |t|
      t.string :type, null: false
      t.text :name, null: false
      t.text :description
      t.text :version
      t.boolean :is_community

      t.references :project, foreign_key: true, index: true
      t.integer :created_by_id, null: false, index: true
      t.integer :updated_by_id, null: false, index: true

      t.timestamps
    end

    add_index :compositions, [:project_id, :type, :name, :version],
      unique: true, nulls_not_distinct: true,
      name: 'composition_unique_name_index'

    add_index :compositions, :is_community

    # Community records have no project, project records always do.
    add_check_constraint :compositions,
      '(is_community IS TRUE) = (project_id IS NULL)',
      name: 'composition_community_project_check'

    add_foreign_key :compositions, :users, column: :created_by_id
    add_foreign_key :compositions, :users, column: :updated_by_id
  end
end
