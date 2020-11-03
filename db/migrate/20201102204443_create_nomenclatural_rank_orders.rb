class CreateNomenclaturalRankOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :nomenclatural_rank_orders do |t|
      t.string :rank_class, null: false
      t.integer :position, null: false

      t.index [:rank_class], unique: true
      t.index [:rank_class, :position] # Also :position so the index itself holds all the data needed for sorting
    end
  end
end
