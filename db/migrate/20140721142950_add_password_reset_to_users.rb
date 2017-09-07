class AddPasswordResetToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :password_reset_token, :string
    add_column :users, :password_reset_token_date, :datetime
  end
end
