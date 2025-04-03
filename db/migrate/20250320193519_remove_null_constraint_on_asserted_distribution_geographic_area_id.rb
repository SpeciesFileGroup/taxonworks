class RemoveNullConstraintOnAssertedDistributionGeographicAreaId < ActiveRecord::Migration[7.2]
  def change
    change_column_null :asserted_distributions, :geographic_area_id, true
  end
end
