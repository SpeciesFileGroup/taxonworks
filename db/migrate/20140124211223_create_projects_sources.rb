class CreateProjectsSources < ActiveRecord::Migration[4.2]
  def change
    create_table :projects_sources do |t|
      t.references :project, index: true
      t.references :source, index: true
      t.integer :created_by_id
      t.integer :updated_by_id

      t.timestamps
    end
  end
end
