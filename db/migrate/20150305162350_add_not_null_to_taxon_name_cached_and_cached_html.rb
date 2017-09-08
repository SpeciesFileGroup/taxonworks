class AddNotNullToTaxonNameCachedAndCachedHtml < ActiveRecord::Migration[4.2]
  def change
    TaxonName.connection.execute('alter table taxon_names alter cached set not null;')
    TaxonName.connection.execute('alter table taxon_names alter cached_html set not null;')
  end
end
