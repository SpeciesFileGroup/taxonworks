class DefaultUserSignInCountToZero < ActiveRecord::Migration
  def change
    remove_column :users, :sign_in_count, :integer
    add_column :users, :sign_in_count, :integer, default: 0
  end
end
