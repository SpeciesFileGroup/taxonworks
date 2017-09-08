class AddBibtexTypeToSource < ActiveRecord::Migration[4.2]
  def change
    add_column :sources, :bibtex_type, :string
  end
end
