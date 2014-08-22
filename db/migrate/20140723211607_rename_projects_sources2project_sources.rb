class RenameProjectsSources2projectSources < ActiveRecord::Migration
  def change
    drop_table :projects_sources
    create_table :project_sources do |t|
      t.integer :project_id
      t.integer :source_id
      t.integer :created_by_id
      t.integer :updated_by_id
      t.timestamp :created_at
      t.timestamp :updated_at
    end
  end
end
