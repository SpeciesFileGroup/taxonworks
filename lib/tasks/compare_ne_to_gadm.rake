# INIT tasks for RGeo, PostGIS, shape files (GADM and TDWG)

namespace :tw do
  namespace :init do

    desc 'Compare the NaturalEarth country name data to the level_0 level data from GADM2.'
    task :compare_ne_to_gadm => :environment do

      matched   = 0
      unmatched = 0
      a3_only   = 0
      index     = 0
      result    = ''

      # ne0_10 = RGeo::Shapefile::Reader.open('G:\Share\Downloads\PostgreSQL\PostGIS\10m_cultural\10m_cultural\ne_10m_admin_0_countries.shp', factory: Georeference::FACTORY)
      ne0_10    = DBF::Table.new('../shapes/NaturalEarth/10m_cultural/ne_10m_admin_0_countries.dbf')
      ne1_10    = DBF::Table.new('../shapes/NaturalEarth/10m_cultural/ne_10m_admin_1_states_provinces_lines_shp.dbf')
      ne0_50    = DBF::Table.new('../shapes/NaturalEarth/50m_cultural/ne_50m_admin_0_countries.dbf')
      ne1_50    = DBF::Table.new('../shapes/NaturalEarth/50m_cultural/ne_50m_admin_1_states_provinces_lines_shp.dbf')
      ne0_110   = DBF::Table.new('../shapes/NaturalEarth/110m_cultural/ne_110m_admin_0_countries.dbf')
      ne1_110   = DBF::Table.new('../shapes/NaturalEarth/110m_cultural/ne_110m_admin_1_states_provinces_lines_shp.dbf')
      # gadm = RGeo::Shapefile::Reader.open('G:\Share\rails\shapes\gadm_v2_shp\gadm2.shp', factory: Georeference::FACTORY)

=begin
      ne1_10.each {|item|
        ne1_name = item.attributes['name']
        if ne1_name =~ /US_/
          puts ne1_name
        end
      }
=end

      ne0_50.each { |item|
        ne_a3   = item.attributes['adm0_a3']
        ne_name = item.attributes['name'].titlecase
        ga      = GeographicArea.where(name: ne_name).first
        if ga.nil?
          unmatched += 1
          result    = "Unmatched (#{index}): #{ne_name} (#{ne_a3})"
          ga3       = GeographicArea.where(iso_3166_a3: ne_a3).first
          if ga3.nil?
            result += ' No A3 match found.'
            puts result
          else
            result    += " Found A3 match: (#{ga3.name})."
            a3_only   += 1
            unmatched -= 1
            matched   += 1
            puts result
          end
        else
          result = "Matched   (#{index}): #{ga.name}"
          if ne_a3 == ga.iso_3166_a3
            result += " (#{ga.iso_3166_a3})"
          else
            result += " (A3 #{ne_a3} did not match.)"
          end
          matched += 1
          puts result
        end
        index += 1
      }
      puts "\nProcessed: #{matched + unmatched}: Unmatched: #{unmatched}, Matched: #{matched} (A3 Only: #{a3_only})."
    end
  end
end

