class AddVerbatimGeographicAreaToAssertedDistributions < ActiveRecord::Migration[4.2]
  def change
    add_column :asserted_distributions, :verbatim_geographic_area, :varchar
  end
end
