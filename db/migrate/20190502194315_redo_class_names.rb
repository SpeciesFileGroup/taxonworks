class RedoClassNames < ActiveRecord::Migration[5.2]
  def change
    TaxonNameRelationship.connection.execute("UPDATE taxon_name_relationships SET type = 'TaxonNameRelationship::Typification::Genus::Original::OriginalMonotypy' WHERE type = 'TaxonNameRelationship::Typification::Genus::Monotypy::Original';")
  end
end
