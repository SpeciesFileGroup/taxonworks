class PostgisExtend < ActiveRecord::Migration[4.2]
  def change
    enable_extension 'postgis'
    enable_extension 'postgis_topology'
  end
end
