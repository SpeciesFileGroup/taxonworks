class DataMigrateCacheGender < ActiveRecord::Migration[7.2]
  def change
    a = Protonym.joins(:taxon_name_classifications)
      .where(taxon_name_classifications: {type: 'TaxonNameClassification::Latinized::Gender::Neuter'})
      .in_batches
    a.update_all(cached_gender: 'neuter')

    b = Protonym.joins(:taxon_name_classifications)
      .where(taxon_name_classifications: {type: 'TaxonNameClassification::Latinized::Gender::Masculine'})
      .in_batches
    b.update_all(cached_gender: 'masculine')

    c = Protonym.joins(:taxon_name_classifications)
      .where(taxon_name_classifications: {type: 'TaxonNameClassification::Latinized::Gender::Feminine'})
      .in_batches
    c.update_all(cached_gender: 'feminine')
  end
end
