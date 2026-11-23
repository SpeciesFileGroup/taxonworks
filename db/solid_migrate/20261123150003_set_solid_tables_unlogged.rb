# Claude provided > 50% of the code for this class.
# PostgreSQL only. Unlogged tables skip WAL; contents are lost on crash and not
# replicated, acceptable for cache/cable data. Isolated here so reverting is
# a rollback (or a new migration) of this file alone.
# Not recorded by schema_format :ruby, so schema-loaded databases stay logged.
class SetSolidTablesUnlogged < ActiveRecord::Migration[8.1]
  TABLES = %w[solid_cache_entries solid_cable_messages].freeze

  def up
    return unless connection.adapter_name == 'PostgreSQL'
    TABLES.each { |t| execute "ALTER TABLE #{t} SET UNLOGGED" }
  end

  def down
    return unless connection.adapter_name == 'PostgreSQL'
    TABLES.each { |t| execute "ALTER TABLE #{t} SET LOGGED" }
  end
end
