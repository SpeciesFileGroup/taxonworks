class AddObservationMatrixIdToLead < ActiveRecord::Migration[7.2]
  def change
    add_reference :leads, :observation_matrix, foreign_key: { on_delete: :nullify }
  end
end
