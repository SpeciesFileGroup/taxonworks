class AddExtensionRaster < ActiveRecord::Migration[6.1]
  def change
    execute 'CREATE EXTENSION IF NOT EXISTS postgis_raster'
    execute 'COMMIT' # Next sentence cannot run inside transaction
    execute "ALTER SYSTEM SET postgis.gdal_enabled_drivers TO 'ENABLE_ALL'"
    execute 'SELECT pg_reload_conf();'
    execute 'BEGIN' # To silence a warning
  end
end
