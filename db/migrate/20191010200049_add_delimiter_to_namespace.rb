class AddDelimiterToNamespace < ActiveRecord::Migration[5.2]
  def change
    add_column :namespaces, :delimiter, :string
  end
end
