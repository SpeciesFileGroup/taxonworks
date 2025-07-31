class AddOtuToObservationMatrix < ActiveRecord::Migration[7.1]
  def change
    add_reference :observation_matrices, :otu, foreign_key: true
  end
end
