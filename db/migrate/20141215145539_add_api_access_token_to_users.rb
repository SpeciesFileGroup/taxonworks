class AddApiAccessTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :api_access_token, :string
  end
end
