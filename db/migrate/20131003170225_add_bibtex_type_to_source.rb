class AddBibtexTypeToSource < ActiveRecord::Migration
  def change
    add_column :sources, :bibtex_type, :string
  end
end
