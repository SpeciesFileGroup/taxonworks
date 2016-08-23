class DeleteSourceIdFromAssertedDistribution < ActiveRecord::Migration
  def change
    remove_foreign_key :asserted_distributions, column: :source_id
    remove_column :asserted_distributions, :source_id

  end
end
