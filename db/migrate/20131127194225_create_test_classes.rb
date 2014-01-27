# This class is only used in rspec stubbing of models
class CreateTestClasses < ActiveRecord::Migration
  def change
    create_table :test_classes do |t|
      t.integer :project_id
      t.integer :created_by_id
      t.integer :updated_by_id
      t.string :string
      t.boolean :boolean
      t.text :text
      t.integer :integer

      t.timestamps
    end
  end
end
