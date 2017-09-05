class AddIsFlaggedForPasswordResetToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :is_flagged_for_password_reset, :boolean, default: false
  end
end
