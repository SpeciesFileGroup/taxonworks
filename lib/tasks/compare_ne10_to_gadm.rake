# INIT tasks for RGeo, PostGIS, shape files (GADM and TDWG)

namespace :tw do
  namespace :init do

    desc 'Compare the NaturalEarth country name data to the level_0 level data from GADM2.'
    task :compare_ne10_to_gadm => :environment do

      matched = 0
      unmatched = 0
      result = ''

      ne10 = RGeo::Shapefile::Reader.open('G:\Share\Downloads\PostgreSQL\PostGIS\10m_cultural\10m_cultural\ne_10m_admin_0_countries.shp', factory: Georeference::FACTORY)
      # gadm = RGeo::Shapefile::Reader.open('G:\Share\rails\shapes\gadm_v2_shp\gadm2.shp', factory: Georeference::FACTORY)

      ne10.each {|item|
        ga = GeographicArea.where(name: item.attributes['name'])
        if ga.nil?
          unmatched += 1
          result = "Unmatched (#{item.index}): #{item.attributes['name']}"
        else
          result = "Matched   (#{item.index}): #{ga.name}"
          matched += 1
        end
        puts result
      }
      puts "Processed: #{matched + unmatched}, Matched: #{matched}, Unmatched: #{unmatched}."
    end
  end
end

