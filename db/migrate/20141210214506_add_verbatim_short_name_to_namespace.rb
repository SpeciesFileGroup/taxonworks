class AddVerbatimShortNameToNamespace < ActiveRecord::Migration
  def change
    add_column :namespaces, :verbatim_short_name, :string
  end
end
