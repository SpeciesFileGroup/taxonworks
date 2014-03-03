class AddOtuIdToContainer < ActiveRecord::Migration
  def change
    add_reference :containers, :otu, index: true
  end
end
