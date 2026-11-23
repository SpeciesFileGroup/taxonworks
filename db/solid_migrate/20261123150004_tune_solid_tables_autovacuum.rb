# Claude provided > 50% of the code for this class.
# PostgreSQL only. Constant insert/delete (cache expiry, cable trimming) needs
# more frequent autovacuum than the defaults. Starting values, tune from production.
# Not recorded by schema_format :ruby, so schema-loaded databases use defaults.
class TuneSolidTablesAutovacuum < ActiveRecord::Migration[8.1]
  TABLES = %w[solid_cache_entries solid_cable_messages].freeze

  SETTINGS = {
    autovacuum_vacuum_scale_factor: 0.01,
    autovacuum_analyze_scale_factor: 0.02,
    autovacuum_vacuum_threshold: 1000
  }.freeze

  def up
    return unless connection.adapter_name == 'PostgreSQL'
    settings = SETTINGS.map { |k, v| "#{k} = #{v}" }.join(', ')
    TABLES.each { |t| execute "ALTER TABLE #{t} SET (#{settings})" }
  end

  def down
    return unless connection.adapter_name == 'PostgreSQL'
    TABLES.each { |t| execute "ALTER TABLE #{t} RESET (#{SETTINGS.keys.join(', ')})" }
  end
end
