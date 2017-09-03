class UpdateTaxonNameColumns < ActiveRecord::Migration[4.2]
  def change
    add_column :taxon_names, :original_spelling, :string
    rename_column :taxon_names, :author, :verbatim_author
  end
end
