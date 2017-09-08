class RemoveColumnVerbatimGeographicAreaFromAssertedDistributions < ActiveRecord::Migration[4.2]
  def change
    remove_column :asserted_distributions, :verbatim_geographic_area
  end
end
