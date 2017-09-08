class Drop < ActiveRecord::Migration[4.2]
  def change
    remove_column :projects, :project_id
  end
end
