class UpdateDateFieldsOnTaxonDetermination < ActiveRecord::Migration
  def change

   remove_column :taxon_determinations, :year_made
   remove_column :taxon_determinations, :month_made
   remove_column :taxon_determinations, :day_made

   add_column :taxon_determinations, :year_made, :integer, size: 4
   add_column :taxon_determinations, :month_made, :integer, size: 2
   add_column :taxon_determinations, :day_made, :integer, size: 2


  end
end
