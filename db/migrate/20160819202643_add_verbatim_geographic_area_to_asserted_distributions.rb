class AddVerbatimGeographicAreaToAssertedDistributions < ActiveRecord::Migration
  def change
    add_column :asserted_distributions, :verbatim_geographic_area, :varchar
  end
end
