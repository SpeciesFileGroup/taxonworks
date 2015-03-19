class AddPagesToCitation < ActiveRecord::Migration
  def change
    add_column :citations, :pages, :string
  end
end
