class PopulateTaxonNameCachedIsValid < ActiveRecord::Migration[6.0]
  # This is a data migration touching only cached values. 
  def change
    TaxonName.that_is_invalid.update_all(cached_is_valid: false)
    TaxonName.that_is_valid.update_all(cached_is_valid: true)
  end
end
