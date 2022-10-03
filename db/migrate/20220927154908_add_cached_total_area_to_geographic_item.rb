class AddCachedTotalAreaToGeographicItem < ActiveRecord::Migration[6.1]

  # === 20220927154908 AddCachedTotalAreaToGeographicItem: migrated (188.5493s) ===
  def change
    add_column :geographic_items, :cached_total_area, :decimal, index: true

    GeographicItem.reset_column_information

    # GC.start
    #Parallel.each(GeographicItem.find_each, progress: 'set_cached', in_processes: 4) do |i|
    #  begin

    GeographicItem.where.not(type: 'GeographicItem::Point').find_each do |i|
      r = i.send(:set_cached)
    end

    GeographicItem::Point.update_all(cached_total_area: 0.0)

    #  rescue => exception
    #    puts "Error - id: #{i.id}"
    #  end
    #end

  end
end
