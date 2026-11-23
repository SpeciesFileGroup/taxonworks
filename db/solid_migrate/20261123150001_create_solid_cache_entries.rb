# Claude provided > 50% of the code for this class.
# Solid Cache table, as the solid_cache installer's db/cache_schema.rb.
# A migration (not a schema file) so existing `db:migrate` flows build it.
class CreateSolidCacheEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :solid_cache_entries, if_not_exists: true do |t|
      t.binary :key, limit: 1024, null: false
      t.binary :value, limit: 536870912, null: false
      t.datetime :created_at, null: false
      t.integer :key_hash, limit: 8, null: false
      t.integer :byte_size, limit: 4, null: false

      t.index :byte_size
      t.index [:key_hash, :byte_size]
      t.index :key_hash, unique: true
    end
  end
end
