#
# !! Time to completion is > 5 minutes for 1my rows
#
class DataMigrateSetCachedIsAvailable < ActiveRecord::Migration[7.2]
  def change
    a = Protonym.joins(:taxon_name_relationships).where(taxon_name_relationships: {type: ::TAXON_NAME_RELATIONSHIP_NAMES_MISSPELLING_AND_MISAPPLICATION})
    b = Protonym.joins(:taxon_name_classifications).where(taxon_name_classifications: {type: ::TAXON_NAME_CLASS_NAMES_UNAVAILABLE})
    c = ::Queries.union(TaxonName, [a,b]).in_batches

    c.update_all(cached_is_available: false)

    d = TaxonName.connection.execute("UPDATE taxon_names SET cached_is_available = '1' WHERE cached_is_available is null;")
  end
end
