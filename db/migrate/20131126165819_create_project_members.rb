class CreateProjectMembers < ActiveRecord::Migration
  def change
    create_table :project_members do |t|
      t.references :project
      t.references :user 

      t.timestamps
    end
  end
end
