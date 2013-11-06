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
  end
end
