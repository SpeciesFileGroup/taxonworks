class RenameOriginalToOriginalMonotypy < ActiveRecord::Migration[5.2]

  ActiveRecord::Base.transaction do
    TaxonNameRelationship.where(type: 'TaxonNameRelationship::Typification::Genus::OriginalDesignation').find_each do |r|
      r.update_column(:type, 'TaxonNameRelationship::Typification::Genus::Original::OriginalDesignation')
    end
    TaxonNameRelationship.where(type: 'TaxonNameRelationship::Typification::Genus::SubsequentDesignation').find_each do |r|
      r.update_column(:type, 'TaxonNameRelationship::Typification::Genus::Subsequent::SubsequentDesignation')
    end
    TaxonNameRelationship.where(type: 'TaxonNameRelationship::Typification::Genus::Monotypy::Subsequent').find_each do |r|
      r.update_column(:type, 'TaxonNameRelationship::Typification::Genus::Subsequent::SubsequentMonotypy')
    end
    TaxonNameRelationship.where(type: 'TaxonNameRelationship::Typification::Genus::RulingByCommission').find_each do |r|
      r.update_column(:type, 'TaxonNameRelationship::Typification::Genus::Subsequent::RulingByCommission')
    end
    TaxonNameRelationship.where(type: 'TaxonNameRelationship::Typification::Genus::Monotypy::OriginalMonotypy').find_each do |r|
      r.update_column(:type, 'TaxonNameRelationship::Typification::Genus::Original::OriginalMonotypy')
    end
    TaxonNameRelationship.where(type: 'TaxonNameRelationship::Typification::Genus::Monotypy').find_each do |r|
      r.update_column(:type, 'TaxonNameRelationship::Typification::Genus::Original::OriginalMonotypy')
    end
  end

end
