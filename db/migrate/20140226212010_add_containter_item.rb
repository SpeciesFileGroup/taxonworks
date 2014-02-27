class AddContainterItem < ActiveRecord::Migration
  def change
    add_column :loan_items, :container_id, :integer
  end
end
