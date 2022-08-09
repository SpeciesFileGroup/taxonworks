class RenameNonBinomialToNonBinominal < ActiveRecord::Migration[6.1]
  def change
    TaxonNameClassification.connection.execute("UPDATE taxon_name_classifications SET type = 'TaxonNameClassification::Iczn::Unavailable::NonBinominal' WHERE type = 'TaxonNameClassification::Iczn::Unavailable::NonBinomial';")
    TaxonNameClassification.connection.execute("UPDATE taxon_name_classifications SET type = 'TaxonNameClassification::Iczn::Unavailable::NonBinominal::SpeciesNotBinominal' WHERE type = 'TaxonNameClassification::Iczn::Unavailable::NonBinomial::SpeciesNotBinomial';")
    TaxonNameClassification.connection.execute("UPDATE taxon_name_classifications SET type = 'TaxonNameClassification::Iczn::Unavailable::NonBinominal::SubspeciesNotTrinominal' WHERE type = 'TaxonNameClassification::Iczn::Unavailable::NonBinomial::SubspeciesNotTrinomial';")
    TaxonNameClassification.connection.execute("UPDATE taxon_name_classifications SET type = 'TaxonNameClassification::Iczn::Unavailable::NonBinominal::NotUninominal' WHERE type = 'TaxonNameClassification::Iczn::Unavailable::NonBinomial::NotUninomial';")

  end
end
