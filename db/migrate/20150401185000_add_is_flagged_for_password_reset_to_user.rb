class AddIsFlaggedForPasswordResetToUser < ActiveRecord::Migration
  def change
    add_column :users, :is_flagged_for_password_reset, :boolean, default: false
  end
end
