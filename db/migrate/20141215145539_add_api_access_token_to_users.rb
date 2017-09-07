class AddApiAccessTokenToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :api_access_token, :string
  end
end
