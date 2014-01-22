# INIT tasks for RGeo, PostGIS, shape files (NaturalEarth, ISO, GADM, TDWG)

namespace :tw do
  namespace :init do

    desc 'Compare the NaturalEarth country name data at 10m, 50m, 110m.'
    task :compare_ne10_50_110 => :environment do

      matched   = 0
      unmatched = 0
      a3_only   = 0
      index     = 0
      result    = ''

      # ne0_10 = RGeo::Shapefile::Reader.open('G:\Share\Downloads\PostgreSQL\PostGIS\10m_cultural\10m_cultural\ne_10m_admin_0_countries.shp', factory: Georeference::FACTORY)
      ne0_10    = DBF::Table.new('../shapes/NaturalEarth/10m_cultural/ne_10m_admin_0_countries.dbf')
      ne1_10    = DBF::Table.new('../shapes/NaturalEarth/10m_cultural/ne_10m_admin_1_states_provinces_lines_shp.dbf')
      ne0_50    = DBF::Table.new('../shapes/NaturalEarth/50m_cultural/ne_50m_admin_0_countries.dbf')
      ne1_50    = DBF::Table.new('../shapes/NaturalEarth/50m_cultural/ne_50m_admin_1_states_provinces_lines.dbf')
      ne0_110   = DBF::Table.new('../shapes/NaturalEarth/110m_cultural/ne_110m_admin_0_countries.dbf')
      ne1_110   = DBF::Table.new('../shapes/NaturalEarth/110m_cultural/ne_110m_admin_1_states_provinces_lines.dbf')
      # gadm = RGeo::Shapefile::Reader.open('G:\Share\rails\shapes\gadm_v2_shp\gadm2.shp', factory: Georeference::FACTORY)

=begin
      ne1_10.each {|item|
        ne1_name = item.attributes['name']
        if ne1_name =~ /US_/
          puts ne1_name
        end
      }
=end

      n10, n50, n110 = {}, {}, {}

      ne0_10.each { |item|
        n10.merge!({item.attributes['adm0_a3'] => item.attributes['name'].titlecase})
      }

      ne0_50.each { |item|
        n50.merge!({item.attributes['adm0_a3'] => item.attributes['name'].titlecase})
      }

      ne0_110.each { |item|
        n110.merge!({item.attributes['adm0_a3'] => item.attributes['name'].titlecase})
      }

      n50.each { |key, value| n10.delete(key) }
      n110.each { |key, value| n50.delete(key) }

      # n110 will be empty
      n50.each { |key, value|
        n110.delete(key)
      }

      # n50 will contain only one object, "{"ATC"=>"Ashmore And Cartier Is."}"
      n10.each { |key, value|
        n50.delete(key)
      }


      n110.each {|key, value|
        n50.delete(key)
        n10.delete(key)
      }

      # all 110m objects are represented in 50m objects.
      # only one 50m object is *not* represented in 10m objects.

    end
  end
end

