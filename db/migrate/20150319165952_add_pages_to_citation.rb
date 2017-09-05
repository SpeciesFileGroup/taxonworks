class AddPagesToCitation < ActiveRecord::Migration[4.2]
  def change
    add_column :citations, :pages, :string
  end
end
