class AddLastSeenAtToProjectMembers < ActiveRecord::Migration[6.1]
  def change
    add_column :project_members, :last_seen_at, :timestamp
  end
end
