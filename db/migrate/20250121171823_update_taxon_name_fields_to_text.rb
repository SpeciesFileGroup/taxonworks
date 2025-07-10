class UpdateTaxonNameFieldsToText < ActiveRecord::Migration[7.2]
  def change
    # Eliminate a lot of ::text in SQL
    change_column :taxon_names, :name, :text
    change_column :taxon_names, :cached_html, :text
    change_column :taxon_names, :cached_author_year, :text
    change_column :taxon_names, :verbatim_author, :text
    change_column :taxon_names, :rank_class, :text
    change_column :taxon_names, :cached_original_combination, :text
    change_column :taxon_names, :cached_secondary_homonym, :text
    change_column :taxon_names, :cached_primary_homonym, :text
    change_column :taxon_names, :cached_secondary_homonym_alternative_spelling, :text
    change_column :taxon_names, :cached_primary_homonym_alternative_spelling, :text
    change_column :taxon_names, :masculine_name, :text
    change_column :taxon_names, :feminine_name, :text
    change_column :taxon_names, :neuter_name, :text
    change_column :taxon_names, :cached_classified_as, :text
    change_column :taxon_names, :cached, :text
    change_column :taxon_names, :verbatim_name, :text
    change_column :taxon_names, :cached_original_combination, :text
    change_column :taxon_names, :cached_author, :text
    change_column :taxon_names, :cached_original_combination_html, :text
  end
end
