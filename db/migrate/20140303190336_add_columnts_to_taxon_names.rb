class AddColumntsToTaxonNames < ActiveRecord::Migration
  def change
    add_column :taxon_names, :masculine_name, :string
    add_column :taxon_names, :feminine_name, :string
    add_column :taxon_names, :neuter_name, :string
    add_column :taxon_names, :gender, :string
  end
end
