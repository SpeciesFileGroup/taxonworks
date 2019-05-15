class AddApiAccessTokenToProject < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :api_access_token, :string
  end
end
