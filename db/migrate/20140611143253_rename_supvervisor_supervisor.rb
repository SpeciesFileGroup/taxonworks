class RenameSupvervisorSupervisor < ActiveRecord::Migration
  def change
    rename_column :loans, :supvervisor_email, :supervisor_email
  end
end
