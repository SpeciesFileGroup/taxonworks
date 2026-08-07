class ElectronicPublications < ActiveRecord::Migration[5.2]

  def change
    TaxonNameClassification.connection.execute("UPDATE taxon_name_classifications SET type = 'TaxonNameClassification::Iczn::Unavailable::ElectronicOnlyPublicationBefore2012' WHERE type = 'TaxonNameClassification::Iczn::Unavailable::NomenNudum::ElectronicOnlyPublicationBefore2012';")
    TaxonNameClassification.connection.execute("UPDATE taxon_name_classifications SET type = 'TaxonNameClassification::Iczn::Unavailable::ElectronicPublicationNotInPdfFormat' WHERE type = 'TaxonNameClassification::Iczn::Unavailable::NomenNudum::ElectronicPublicationNotInPdfFormat';")
    TaxonNameClassification.connection.execute("UPDATE taxon_name_classifications SET type = 'TaxonNameClassification::Iczn::Unavailable::ElectronicPublicationWithoutIssnOrIsbn' WHERE type = 'TaxonNameClassification::Iczn::Unavailable::NomenNudum::ElectronicPublicationWithoutIssnOrIsbn';")
    TaxonNameClassification.connection.execute("UPDATE taxon_name_classifications SET type = 'TaxonNameClassification::Iczn::Unavailable::ElectronicPublicationNotRegisteredInZoobank' WHERE type = 'TaxonNameClassification::Iczn::Unavailable::NomenNudum::ElectronicPublicationNotRegisteredInZoobank';")
  end
end