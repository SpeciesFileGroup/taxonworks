=begin

  (Re)Building the Geographic data

  In Rails.root directory (/taxonworks):

  1:  rake db:drop RAILS_ENV=development && rake db:create RAILS_ENV=development && rake db:migrate RAILS_ENV=development && rake db:seed RAILS_ENV=development
      (Make sure that there are no processes connected to the development data base, including (but not limited to:
        pgAdmin
        psql
        RubyMine))

  2:  rake tw:development:data:geo:build_geographic_areas data_directory=$HOME/src/gaz/ user_id=1 database_role=taxonworks_development NO_GEO_NESTING=1 NO_GEO_VALID=1

  3:  rake tw:development:data:geo:build_geographic_items_from_temporary_shape_tables data_directory=/Users/tuckerjd/src/gaz/ database_role=taxonworks_development user_id=1

  4:  rake tw:development:data:geo:rebuild_geographic_areas_nesting

  (Reloading)
  1: rake db:drop RAILS_ENV=development && rake db:create RAILS_ENV=development && rake db:migrate RAILS_ENV=development && rake db:seed RAILS_ENV=development
      (Make sure that there are no processes connected to the development data base, including (but not limited to:
        pgAdmin
        psql
        RubyMine))

  2.  rake tw:development:data:geo:restore_geo_data_from_pg_dump data_directory=/Users/tuckerjd/src/gaz/data/internal/dump/

  3:  rake tw:development:data:geo:rebuild_geographic_areas_nesting

=end

namespace :tw do


  namespace :development do
    namespace :data do
      # Methods are deprecated, round tripping by pg dumps will be standard in "canvas"
      namespace :geo do

        # TODO: This task is returned to facilitate production of a GeoObject-only database.
        # TODO: still requires testing: tuckerjd@uiuc.edu
        desc "Restore geographic area information from compressed form. Pass the path to gaz's /dump directory to data_directory.\n
          rake tw:initialization:restore_geo_data_from_pg_dump data_directory=/Users/matt/src/sf/tw/gaz/data/internal/dump/"
        task restore_geo_data_from_pg_dump: [:environment, :data_directory] do |t|
          data_store = @args[:data_directory]

          geographic_areas_file                  = "#{data_store}geographic_areas.dump"
          geographic_area_types_file             = "#{data_store}geographic_area_types.dump"
          geographic_items_file                  = "#{data_store}geographic_items.dump"
          geographic_areas_geographic_items_file = "#{data_store}geographic_areas_geographic_items.dump"

          raise "Missing #{geographic_areas_file}, doing nothing." unless File.exists?(geographic_areas_file)
          raise "Missing #{geographic_items_file}, doing nothing." unless File.exists?(geographic_items_file)
          raise "Missing #{geographic_area_types_file}, doing nothing." unless File.exists?(geographic_area_types_file)
          raise "Missing #{geographic_areas_geographic_items_file}, doing nothing." unless File.exists?(geographic_areas_geographic_items_file)

          puts "#{Time.now.strftime "%H:%M:%S"}: From #{geographic_area_types_file}"

          a = Support::Database.pg_restore('geographic_area_types', data_store)
          ApplicationRecord.connection.reset_pk_sequence!('geographic_area_types')
          puts "#{Time.now.strftime "%H:%M:%S"}: From #{geographic_areas_file}"

          c = Support::Database.pg_restore('geographic_areas', data_store)
          ApplicationRecord.connection.reset_pk_sequence!('geographic_areas')
          puts "#{Time.now.strftime "%H:%M:%S"}: From #{geographic_items_file}"

          b = Support::Database.pg_restore('geographic_items', data_store)
          ApplicationRecord.connection.reset_pk_sequence!('geographic_items')
          puts "#{Time.now.strftime "%H:%M:%S"}: From #{geographic_areas_geographic_items_file}"

          d = Support::Database.pg_restore('geographic_areas_geographic_items', data_store)
          ApplicationRecord.connection.reset_pk_sequence!('geographic_areas_geographic_items')
          puts "#{Time.now.strftime "%H:%M:%S"}."
        end

        desc "Restore geographic area information from compressed form. Pass the path to gaz's /dump directory to data_directory.\n
          rake tw:initialization:restore_geo_data_from_pg_dump data_directory=/Users/matt/src/sf/tw/gaz/data/internal/dump/"
        task restore_ce_data_from_pg_dump: [:environment, :data_directory] do |t|
          data_store = @args[:data_directory]

          Rake::Task['tw:initialize:load_geo'].execute

          collecting_events_file = "#{data_store}collecting_events.dump"
          georeferences_file     = "#{data_store}georeferences.dump"

          raise "Missing #{collecting_events_file}, doing nothing." unless File.exists?(collecting_events_file)
          raise "Missing #{georeferences_file}, doing nothing." unless File.exists?(georeferences_file)

          puts "#{Time.now.strftime "%H:%M:%S"}: From #{collecting_events_file}"
          e = Support::Database.pg_restore('collecting_events', data_store)
          ApplicationRecord.connection.reset_pk_sequence!('collecting_events')

          puts "#{Time.now.strftime "%H:%M:%S"}: From #{georeferences_file}"
          f = Support::Database.pg_restore('georeferences', data_store)
          ApplicationRecord.connection.reset_pk_sequence!('georeferences')

          GeographicArea.rebuild!
          puts "#{Time.now.strftime "%H:%M:%S"}."
        end

        # Assumes input is from rake tw:export:table table_name=geographic_area_types
        desc "Load the geographic area types in /gaz via ActiveRecord.\n
            'rake tw:initialization:load_geographic_area_types data_directory=/Users/matt/src/sf/tw/gaz/'"
        task load_geographic_area_types: [:environment, :data_directory] do
          data_file = @args[:data_directory] + 'data/internal/csv/geographic_area_types.csv' # args.with_defaults(:data_file => '../gaz/data/internal/csv/geographic_area_types.csv')
          raise 'There are existing geographic_area_types, doing nothing.' if GeographicAreaType.all.count > 0
          begin
            data = CSV.read(data_file, options = {headers: true, col_sep: "\t"})
            ApplicationRecord.transaction do
              count = data.count
              puts
              data.each { |row|
                r = GeographicAreaType.new(row.to_h)
                r.save!
                print "Save:   record #{r.id} of #{count}.\r"
              }
            end
            puts
          rescue
            raise
          end
        end

        # Assumes input is from rake tw:export:table table_name=geographic_area
        desc "Load the geographic areas in /gaz via ActiveRecord.\n
          'rake tw:initialization:load_geographic_areas data_directory=/Users/matt/src/sf/tw/gaz/ NO_GEO_NESTING=1'"
        task :load_geographic_areas, [:data_file] => [:environment, :data_directory] do
          data_file = @args[:data_directory] + 'data/internal/csv/geographic_areas.csv'

          raise 'There are existing geographic_areas, doing nothing.' if GeographicArea.all.count > 0
          raise "GeographicAreaTypes must be loaded first: run 'rake tw:initialization:load_geographic_area_types data_directory=#{@args[:data_directory]}\' first." if GeographicAreaType.all.count < 1
          raise "GeographicItems must be loaded first: run 'rake tw:initialization:load_geographic_items data_directory=#{@args[:data_directory]}\' first." if GeographicItem.all.count < 1

          begin
            puts "#{Time.now.strftime "%H:%M:%S"}."
            data    = CSV.read(:data_file, options = {headers: true, col_sep: "\t"})
            records = {}

            ApplicationRecord.transaction do
              data.each { |row|
                row_data      = row.to_h
                #row_data.delete('rgt')
                #row_data.delete('lft')
                r             = GeographicArea.new(row_data)
                records[r.id] = r
                print "\rBuild:  record #{r.id}"
              }

              count = records.count
              puts

              records.each_value do |v|
                #snap      = Time.now
                #elapsed   = snap - time_then
                #time_then = snap

                v.level0               = records[v.level0_id]
                v.level1               = records[v.level1_id]
                v.level2               = records[v.level2_id]
                v.parent               = records[v.parent_id]
                v.geographic_area_type = GeographicAreaType.where(id: v.geographic_area_type_id).first
                print "\rUpdate: record #{v.id} of #{count}."
              end
              puts

              records.each_value do |r|
                #snap      = Time.now
                #elapsed   = snap - time_then
                #time_then = snap

                r.save!
                print "\rSave:   record #{r.id} of #{count}"
                #print ": #{Time.at(elapsed).getgm.strftime "%S:%L"}"
                print '.'
              end
              puts "\n\n#{Time.now.strftime "%H:%M:%S"}."
            end
          rescue
            raise
          end
        end

        # Assumes input is from rake tw:export:table table_name=geographic_items
        desc "Load the geographic items in /gaz via ActiveRecord.\n
          'rake tw:initialization:load_geographic_areas data_directory=/Users/matt/src/sf/tw/gaz/ NO_GEO_NESTING=1'"
        task load_geographic_items: [:environment, :data_directory] do
          data_file = @args[:data_directory] + 'data/internal/csv/geographic_items.csv'
          raise 'There are existing geographic_items, doing nothing.' if GeographicItem.all.count > 0
          begin
            data    = CSV.read(data_file, options = {headers: true, col_sep: "\t"})
            records = {}

            count = data.count
            puts "#{args[:data_file]}: #{count} records."
            puts "#{Time.now.strftime "%H:%M:%S"}."

            #ApplicationRecord.transaction do
            data.each { |row|
              row_data      = row.to_h
              #row_data.delete('rgt')
              #row_data.delete('lft')
              r             = GeographicItem.new(row_data)
              records[r.id] = r
              print "\rBuild:  record #{r.id}"
            }

            puts "Write start: #{Time.now.strftime "%H:%M:%S"}."

            records.each_value do |r|
              r.save!
              print "\rSave:   record #{r.id} of #{count}"
            end
            puts "\n\n Write end: #{Time.now.strftime "%H:%M:%S"}.\n\n"

              #end
          rescue
            raise
          end
        end
      end
    end

  end
end
