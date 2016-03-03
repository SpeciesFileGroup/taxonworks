class DataMigrationBuildClosureTrees < ActiveRecord::Migration
  def change
    TaxonName.rebuild!
    Container.rebuild!
    GeographicArea.rebuild!
  end
end
