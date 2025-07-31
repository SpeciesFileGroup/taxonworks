class AddIsPublicToObservationMatrix < ActiveRecord::Migration[7.1]
  def change
    add_column :observation_matrices, :is_public, :boolean
  end
end
