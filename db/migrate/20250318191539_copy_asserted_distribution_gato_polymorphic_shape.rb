class CopyAssertedDistributionGatoPolymorphicShape < ActiveRecord::Migration[7.2]
  def change
    ApplicationRecord.connection.execute(
      "UPDATE asserted_distributions SET asserted_distribution_shape_type = 'GeographicArea', asserted_distribution_shape_id = geographic_area_id;"
    )
  end
end
