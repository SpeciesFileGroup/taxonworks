class TweakTaxonDeterminations < ActiveRecord::Migration
  def change
    remove_column :taxon_determinations, :year_made
    remove_column :taxon_determinations, :month_made
    remove_column :taxon_determinations, :day_made
    remove_column :taxon_determinations, :verbatim
    add_column :taxon_determinations, :year_made, :string, length: 8 
    add_column :taxon_determinations, :month_made, :string, length: 16
    add_column :taxon_determinations, :day_made, :string, length: 4 
  end
end
