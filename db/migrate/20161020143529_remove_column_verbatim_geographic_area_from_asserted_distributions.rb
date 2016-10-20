class RemoveColumnVerbatimGeographicAreaFromAssertedDistributions < ActiveRecord::Migration
  def change
    remove_column :asserted_distributions, :verbatim_geographic_area
  end
end
