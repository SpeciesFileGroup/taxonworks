class RenameBasionymRelationship < ActiveRecord::Migration[5.2]

  def change
    TaxonNameRelationship.connection.execute("UPDATE taxon_name_relationships SET type = 'TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic::Basionym' WHERE type = 'TaxonNameRelationship::Icn::Unaccepting::Usage::Basionym';")
  end
end
