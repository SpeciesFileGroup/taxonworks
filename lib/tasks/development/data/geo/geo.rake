namespace :tw do
  namespace :development do
    namespace :data do
      namespace :geo do

        # Pre-initialization tasks for geo-related data
        SFG          = 'SpeciesFile Group'

        # ISO Country Codes:
        # See http://www.iso.org/iso/home/standards/country_codes.htm

        ISO_3166_1_2 = 'ISO 3166-1-alpha-2' # ISO 3166-1:2006 two-letter country abbreviations
        ISO_3166_1_3 = 'ISO 3166-1-alpha-3' # ISO 3166-1:2006 three-letter country abbreviations

        # Other current choices are:
        ISO_3166_3   = 'ISO 3166-3:1999' # Country names which have been deleted from -1 since 1974
        ISO_3166_2   = 'ISO 3166-2:2007' # State or Province level for country codes in 3166-1

        TDWG2_L1 = 'TDWG2 Level 1'
        TDWG2_L2 = 'TDWG2 Level 2'
        TDWG2_L3 = 'TDWG2 Level 3'
        TDWG2_L4 = 'TDWG2 Level 4'

        GADM2_0 = 'GADM2 Level 0'
        GADM2_1 = 'GADM2 Level 1'
        GADM2_2 = 'GADM2 Level 2'

        NE0_10 = 'NaturalEarth-0 (10m)'
        NE1_10 = 'NaturalEarth-1 (10m)'
        NE_50  = 'NaturalEarth (50m)'
        NE_110 = 'NaturalEarth (110m)'

        EXTRA = 'Extra'

        IMPORT_TABLES = {
          gadm:           "data/external/shapefiles/gadm/gadm_v2_shp/gadm2",
          ne_countries:   "data/external/shapefiles/NaturalEarth/10m_cultural/ne_10m_admin_0_countries",
          ne_states:      "data/external/shapefiles/NaturalEarth/10m_cultural/ne_10m_admin_1_states_provinces_shp",
          tdwg_l1:        "data/external/shapefiles/tdwg/level1/level1",
          tdwg_l2:        "data/external/shapefiles/tdwg/level2/level2",
          tdwg_l3:        "data/external/shapefiles/tdwg/level3/level3",
          tdwg_l4:        "data/external/shapefiles/tdwg/level4/level4"
        }

        task :geo_dev_init do
          raise 'Can not be run in production' if Rails.env == 'production'
        end

        desc "Load the supporting data in SFGs /gaz repo\n
         rake tw:development:data:geo:build_temporary_shapefile_tables data_directory=/Users/matt/src/sf/tw/gaz/ database_role=matt"
        task :build_temporary_shapefile_tables => [:environment, :database_role, :data_directory, :geo_dev_init] do
          puts "Adding temporary shape files."
          IMPORT_TABLES.each do |table_name, file_path|
            if !table_exists(table_name) 
              file = "#{@args[:data_directory]}#{file_path}.shp"
              puts `shp2pgsql -W LATIN1 #{file} #{table_name} > /tmp/foo.sql`
              puts `psql #{@args[:database_role]} -d taxonworks_development -f /tmp/foo.sql` 
              puts `rm /tmp/foo.sql` 
            else
              puts "Table #{table_name} exists, skipping."
            end
            # cleanup TDWG - there is one duplicate record in level 4
            # ActiveRecord::Base.connection.execute('delete from tdwg_l4 where gid = 193;')
          end
        end

        desc 'Remove tables added through build_temporary_shapefile_tables'
        task :delete_temporary_shapefile_tables => [:environment, :geo_dev_init] do
          puts "Deleting temporary shape files."
          IMPORT_TABLES.each do |table_name, file_path|
            if table_exists(table_name) 
              puts "Dropping #{table_name}."
              ActiveRecord::Base.connection.execute("drop table #{table_name};")
            end
          end
        end
      end
    end
  end
end
