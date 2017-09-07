class AddPrintLabelToTaxonDeterimination < ActiveRecord::Migration[5.1]
  def change
    add_column :taxon_determinations, :print_label, :text
  end
end
