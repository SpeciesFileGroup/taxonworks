class UpdateMissapplicationRelationship < ActiveRecord::Migration[6.1]

  def change
    TaxonNameRelationship.connection.execute("UPDATE taxon_name_relationships SET type = 'TaxonNameRelationship::Iczn::Invalidating::Misapplication' WHERE type = 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misapplication';")
  end
end