class RenameOriginalToOriginalMonotypy < ActiveRecord::Migration[5.2]

  def change
    #### Active record does not find classes which do not exist
    #
#    TaxonNameRelationship.where(type: 'TaxonNameRelationship::Typification::Genus::OriginalDesignation').find_each do |r|
#      r.update_column(:type, 'TaxonNameRelationship::Typification::Genus::Original::OriginalDesignation')
#    end
#    TaxonNameRelationship.where(type: 'TaxonNameRelationship::Typification::Genus::SubsequentDesignation').find_each do |r|
#      r.update_column(:type, 'TaxonNameRelationship::Typification::Genus::Subsequent::SubsequentDesignation')
#    end
#    TaxonNameRelationship.where(type: 'TaxonNameRelationship::Typification::Genus::Monotypy::Subsequent').find_each do |r|
#      r.update_column(:type, 'TaxonNameRelationship::Typification::Genus::Subsequent::SubsequentMonotypy')
#    end
#    TaxonNameRelationship.where(type: 'TaxonNameRelationship::Typification::Genus::RulingByCommission').find_each do |r|
#      r.update_column(:type, 'TaxonNameRelationship::Typification::Genus::Subsequent::RulingByCommission')
#    end
#    TaxonNameRelationship.where(type: 'TaxonNameRelationship::Typification::Genus::Monotypy::OriginalMonotypy').find_each do |r|
#      r.update_column(:type, 'TaxonNameRelationship::Typification::Genus::Original::OriginalMonotypy')
#    end
#    TaxonNameRelationship.where(type: 'TaxonNameRelationship::Typification::Genus::Monotypy').find_each do |r|
#      r.update_column(:type, 'TaxonNameRelationship::Typification::Genus::Original::OriginalMonotypy')
#    end

    TaxonNameRelationship.connection.execute("UPDATE taxon_name_relationships SET type = 'TaxonNameRelationship::Typification::Genus::Original::OriginalDesignation' WHERE type = 'TaxonNameRelationship::Typification::Genus::OriginalDesignation';")
    TaxonNameRelationship.connection.execute("UPDATE taxon_name_relationships SET type = 'TaxonNameRelationship::Typification::Genus::Subsequent::SubsequentDesignation' WHERE type = 'TaxonNameRelationship::Typification::Genus::SubsequentDesignation';")
    TaxonNameRelationship.connection.execute("UPDATE taxon_name_relationships SET type = 'TaxonNameRelationship::Typification::Genus::Subsequent::SubsequentMonotypy' WHERE type = 'TaxonNameRelationship::Typification::Genus::Monotypy::Subsequent';")
    TaxonNameRelationship.connection.execute("UPDATE taxon_name_relationships SET type = 'TaxonNameRelationship::Typification::Genus::Subsequent::RulingByCommission' WHERE type = 'TaxonNameRelationship::Typification::Genus::RulingByCommission';")
    TaxonNameRelationship.connection.execute("UPDATE taxon_name_relationships SET type = 'TaxonNameRelationship::Typification::Genus::Original::OriginalMonotypy' WHERE type = 'TaxonNameRelationship::Typification::Genus::Monotypy::OriginalMonotypy';")
    TaxonNameRelationship.connection.execute("UPDATE taxon_name_relationships SET type = 'TaxonNameRelationship::Typification::Genus::Original::OriginalMonotypy' WHERE type = 'TaxonNameRelationship::Typification::Genus::Monotypy';")
  end

end
