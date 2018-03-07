class AddContainterItem < ActiveRecord::Migration[4.2]
  def change
    add_column :loan_items, :container_id, :integer
  end
end
