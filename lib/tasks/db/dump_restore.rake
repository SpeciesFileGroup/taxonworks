require 'rake'
require 'benchmark'

namespace :tw do
  namespace :db do
    desc 'Dump the data to a PostgreSQL custom-format dump file'
    task :dump => [:environment, :data_directory, :db_user] do
      database = ActiveRecord::Base.connection.current_database
      path     = File.join(@args[:data_directory], Time.now.utc.strftime('%Y-%m-%d_%H%M%S%Z') + '.dump')

      puts "Dumping #{database} to #{path}"
      puts(Benchmark.measure { `pg_dump --username=#{ENV["db_user"]} --format=custom #{database} --file=#{path}` })
      raise "pg_dump failed with exit code #{$?.to_i}" unless $? == 0
      puts 'Dump complete'

      raise 'Failed to create dump file' unless File.exists?(path)
    end

    desc 'Dump the data as a backup, then restore the db from the specified file.'
    task :restore => [:dump, :environment, :data_directory, :db_user] do
      raise 'Specify a dump file: rake tw:db:restore file=myfile.dump' if not ENV['file']
      Rake::Task['db:drop'].invoke
      raise "'db:drop' failed with exit code #{$?.to_i}" unless $? == 0
      Rake::Task['db:create'].invoke
      raise "'db:create' failed with exit code #{$?.to_i}" unless $? == 0
      database = ActiveRecord::Base.connection.current_database
      path     = File.join(@args[:data_directory], ENV["file"])
      puts "Restoring #{database} from #{path}"
      puts(Benchmark.measure { `pg_restore --username=#{ENV["db_user"]} --format=custom --disable-triggers --dbname=#{database} #{path}` })
      raise "pg_restore failed with exit code #{$?.to_i}" unless $? == 0
      puts 'Restore complete'
    end

    desc 'Restore from youngest dump file. Handy!'
    task :restore_last => [:find_last, :restore]

    task :find_last => [:environment, :data_directory] do
      file = Dir[File.join(@args[:data_directory], '*.dump')].sort.last
      raise 'No dump has been found' unless file
      ENV['file'] = File.basename(file)
    end

    task :db_user => [:environment] do
      ENV['db_user'] = Rails.configuration.database_configuration[Rails.env]['username'] if ENV['db_user'].blank?
    end
  end
end
