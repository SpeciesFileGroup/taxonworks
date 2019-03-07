class AddOrganizationToRole < ActiveRecord::Migration[5.2]
  def change
    add_reference :roles, :organization, foreign_key: true
  end
end
