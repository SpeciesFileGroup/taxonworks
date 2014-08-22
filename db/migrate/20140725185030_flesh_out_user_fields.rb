class FleshOutUserFields < ActiveRecord::Migration
  def change
    add_column :users, :name, :string
    add_column :users, :sign_in_count, :integer
    add_column :users, :current_sign_in_at, :datetime
    add_column :users, :last_sign_in_at, :datetime
    add_column :users, :current_sign_in_ip, :string # see postgres_ext gem though
    add_column :users, :last_sign_in_ip, :string
  end
end
