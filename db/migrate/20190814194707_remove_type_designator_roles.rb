class RemoveTypeDesignatorRoles < ActiveRecord::Migration[5.2]
  def change
    Role.connection.execute("delete from roles where type = 'TypeDesignator';")
  end
end
