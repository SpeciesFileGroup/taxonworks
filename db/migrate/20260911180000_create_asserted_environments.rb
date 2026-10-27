class CreateAssertedEnvironments < ActiveRecord::Migration[7.2]
  def change
    create_table :asserted_environments do |t|
      t.bigint :asserted_environment_object_id, null: false
      t.string :asserted_environment_object_type, null: false
      t.text :uri, null: false
      t.text :uri_label, null: false
      t.text :cached
      t.integer :position

      t.references :project, foreign_key: true, null: false
      t.integer :created_by_id, null: false, index: true
      t.integer :updated_by_id, null: false, index: true

      t.timestamps
    end

    add_index :asserted_environments,
      [:asserted_environment_object_id, :asserted_environment_object_type],
      name: 'asserted_environment_polymorphic_object_index'

    add_index :asserted_environments, :uri

    add_foreign_key :asserted_environments, :users, column: :created_by_id
    add_foreign_key :asserted_environments, :users, column: :updated_by_id
  end
end
