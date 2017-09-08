class RenameSupvervisorSupervisor < ActiveRecord::Migration[4.2]
  def change
    rename_column :loans, :supvervisor_email, :supervisor_email
  end
end
