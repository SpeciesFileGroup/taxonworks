class AddStrataToCollectingEvent < ActiveRecord::Migration[4.2]
  def change
    add_column :collecting_events, :group, :string
    add_column :collecting_events, :formation, :string
    add_column :collecting_events, :member, :string
    add_column :collecting_events, :lithology, :string
    add_column :collecting_events, :max_ma, :decimal
    add_column :collecting_events, :min_ma, :decimal
  end
end
