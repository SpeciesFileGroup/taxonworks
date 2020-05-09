class AddIsInProgressToSqedDepiction < ActiveRecord::Migration[6.0]
  def change
    add_column :sqed_depictions, :in_progress, :datetime, default: nil 
  end
end
