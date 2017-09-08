class DataMigrationBuildClosureTrees < ActiveRecord::Migration[4.2]
  def change
    # !! not original, updated to reflect absence in Container
    TaxonName.rebuild! if TaxonName.respond_to?(:rebuild!)
    Container.rebuild! if Container.respond_to?(:rebuild!)
    GeographicArea.rebuild! if GeographicArea.respond_to?(:rebuild!)
  end
end
