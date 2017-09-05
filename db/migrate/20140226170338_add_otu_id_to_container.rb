class AddOtuIdToContainer < ActiveRecord::Migration[4.2]
  def change
    add_reference :containers, :otu, index: true
  end
end
