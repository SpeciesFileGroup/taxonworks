require 'rake'
require 'benchmark'
require_relative '../support/database'

namespace :tw do
  namespace :db do
    desc "Dump the data to a PostgreSQL custom-format dump file"

    task :dump_data => :environment do
      database = ActiveRecord::Base.connection.current_database
      file = Time.now.utc.strftime("%Y%m%d-%H%M%S%Z") + '.dump'
      result = 1
      
      puts "Dumping data"
      puts(Benchmark.measure { result = Support::Database.pg_dump_all(database, Settings.db_dumps_dir, file) }) 
      raise "pg_dump failed with exit code #{result}" unless result == 0
      
      # did we write a file?
      raise "Failed to create dump file" unless File.exists?(File.join(Settings.db_dumps_dir, file))
    end
  end
end
