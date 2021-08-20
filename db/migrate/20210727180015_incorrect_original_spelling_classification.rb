class IncorrectOriginalSpellingClassification < ActiveRecord::Migration[5.2]

  def change
    TaxonNameClassification.connection.execute("UPDATE taxon_name_classifications SET type = 'TaxonNameClassification::Iczn::Unavailable::NotLatin' WHERE type = 'TaxonNameClassification::Iczn::Unavailable::IncorrectOriginalSpelling';")
  end
end