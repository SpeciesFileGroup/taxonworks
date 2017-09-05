class AddVerbatimShortNameToNamespace < ActiveRecord::Migration[4.2]
  def change
    add_column :namespaces, :verbatim_short_name, :string
  end
end
