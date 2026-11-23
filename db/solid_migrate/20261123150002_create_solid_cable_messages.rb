# Claude provided > 50% of the code for this class.
# Solid Cable table, as the solid_cable installer's db/cable_schema.rb.
# A migration (not a schema file) so existing `db:migrate` flows build it.
class CreateSolidCableMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :solid_cable_messages, if_not_exists: true do |t|
      t.binary :channel, limit: 1024, null: false
      t.binary :payload, limit: 536870912, null: false
      t.datetime :created_at, null: false
      t.integer :channel_hash, limit: 8, null: false

      t.index :channel
      t.index :channel_hash
      t.index :created_at
    end
  end
end
