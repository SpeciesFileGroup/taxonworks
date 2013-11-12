# require 'fileutils'

namespace :tw do
  namespace :init do

    desc 'Generate PostGIS records for shapefiles.'
    task  :build_geographic_areas do

      place = ENV['place']
      # build csv file list from 'place'

      Dir.glob('*.csv').each { |file|
        CSV.read(file)
      }
      not_done = true
    end
    desc 'Generate GeographicAreaType table.'
    task :gen_geo_a_t_table do
      ['Continent',
       'Country',
       'State',
       'Federal District',
       'County',
       'Borough',
       'Census Area',
       'Municipality',
       'City And Borough',
       'City And County',
       'District',
       'Water body',
       'Parish',
       'Independent City',
       'Province',
       'Ward',
       'Prefecture'].each { |item|

        area_type = GeographicAreaType.where(name: item)[0]
        if area_type.nil?
          at = GeographicAreaType.new(name: item)
          at.save
        end
      }
    end

  end
end
