class AddClipboardToProjectMember < ActiveRecord::Migration[5.1]
  def change
    add_column :project_members, :clipboard, :jsonb, default: {}
  end
end
