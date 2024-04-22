class AddTimeActiveToProjectMembers < ActiveRecord::Migration[6.1]
  def change
    add_column :project_members, :time_active, :integer, default: 0
  end
end
