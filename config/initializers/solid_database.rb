# Refuse to boot if the solid database (Solid Cache, Solid Cable) is the primary database.
# See Support::Database.assert_solid_separate!
Rails.application.config.after_initialize do
  # Asset precompilation (Dockerfile) boots against a single nulldb database, no connections are made.
  next if Support::Database.primary_config[:adapter] == 'nulldb'

  Support::Database.assert_solid_separate!(Support::Database.primary_config, Support::Database.solid_config)
end
