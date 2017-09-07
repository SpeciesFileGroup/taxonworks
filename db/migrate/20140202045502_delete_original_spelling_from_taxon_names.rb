class DeleteOriginalSpellingFromTaxonNames < ActiveRecord::Migration[4.2]
  def change
    remove_column :taxon_names, :original_spelling
  end
end
