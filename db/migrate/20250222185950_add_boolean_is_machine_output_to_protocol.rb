class AddBooleanIsMachineOutputToProtocol < ActiveRecord::Migration[7.2]
  def change
    add_column :protocols, :is_machine_output, :boolean
  end
end
