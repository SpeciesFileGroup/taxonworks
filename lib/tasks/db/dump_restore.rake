require 'rake'
require 'benchmark'

namespace :tw do
  namespace :db do
    desc "Dump the data to a PostgreSQL custom-format dump file"

    task :dump => [:environment, :data_directory] do
      database = ActiveRecord::Base.connection.current_database
      path = File.join(@args[:data_directory], Time.now.utc.strftime("%Y-%m-%d_%H%M%S%Z") + '.dump')
      
      puts "Dumping database to #{path}" 
      puts(Benchmark.measure { `pg_dump -Fc #{database} -f #{path}` }) 
      raise "pg_dump failed with exit code #{$?.to_i}" unless $? == 0
      puts "Dump complete"
      
      raise "Failed to create dump file" unless File.exists?(path)
    end
    
    desc "Dump the data as a backup, then restore the db from the specified file."
    task :restore => :dump do
      raise "Specify a dump file: rake tw:db:restore file=myfile.dump" if not ENV["file"]      
      database = ActiveRecord::Base.connection.current_database
      path = File.join(@args[:data_directory], ENV["file"])
      puts "Restoring database from #{path}"
      puts(Benchmark.measure { `pg_restore -Fc -c -d #{database} #{path}` })
      raise "pg_restore failed with exit code #{$?.to_i}" unless $? == 0
      puts "Restore complete"  
    end

    desc "Restore from youngest dump file. Handy!"
    task :restore_last => [:find_last, :restore]
    
    task :find_last => [:environment, :data_directory] do
      file = Dir[File.join(@args[:data_directory], '*.dump')].sort.last
      raise "No dump has been found" unless file
      ENV["file"] = File.basename(file)
    end    
  end
end
