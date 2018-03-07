class DeleteSourceIdFromAssertedDistribution < ActiveRecord::Migration[4.2]
  def change
    remove_foreign_key :asserted_distributions, column: :source_id
    remove_column :asserted_distributions, :source_id

  end
end
