class RenameOriginalToOriginalMonotypy < ActiveRecord::Migration[5.2]

  def change
    TaxonNameRelationship.connection.execute("UPDATE taxon_name_relationships SET type = 'TaxonNameRelationship::Typification::Genus::Original::OriginalDesignation' WHERE type = 'TaxonNameRelationship::Typification::Genus::OriginalDesignation';")
    TaxonNameRelationship.connection.execute("UPDATE taxon_name_relationships SET type = 'TaxonNameRelationship::Typification::Genus::Subsequent::SubsequentDesignation' WHERE type = 'TaxonNameRelationship::Typification::Genus::SubsequentDesignation';")
    TaxonNameRelationship.connection.execute("UPDATE taxon_name_relationships SET type = 'TaxonNameRelationship::Typification::Genus::Subsequent::SubsequentMonotypy' WHERE type = 'TaxonNameRelationship::Typification::Genus::Monotypy::Subsequent';")
    TaxonNameRelationship.connection.execute("UPDATE taxon_name_relationships SET type = 'TaxonNameRelationship::Typification::Genus::Subsequent::RulingByCommission' WHERE type = 'TaxonNameRelationship::Typification::Genus::RulingByCommission';")
    TaxonNameRelationship.connection.execute("UPDATE taxon_name_relationships SET type = 'TaxonNameRelationship::Typification::Genus::Original::OriginalMonotypy' WHERE type = 'TaxonNameRelationship::Typification::Genus::Monotypy::OriginalMonotypy';")
    TaxonNameRelationship.connection.execute("UPDATE taxon_name_relationships SET type = 'TaxonNameRelationship::Typification::Genus::Original::OriginalMonotypy' WHERE type = 'TaxonNameRelationship::Typification::Genus::Monotypy';")
  end

end
