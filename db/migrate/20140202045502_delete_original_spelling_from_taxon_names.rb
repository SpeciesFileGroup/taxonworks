class DeleteOriginalSpellingFromTaxonNames < ActiveRecord::Migration
  def change
    remove_column :taxon_names, :original_spelling
  end
end
