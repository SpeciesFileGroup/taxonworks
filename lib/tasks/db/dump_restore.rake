require 'rake'
require 'benchmark'

namespace :tw do
  namespace :db do

    desc 'Dump the data to a PostgreSQL custom-format dump file does NOT include structure'
    task :dump => [:environment, :backup_directory, :db_user] do
      if Support::Database.pg_database_exists?
        puts "Initializing dump for #{Rails.env} environment".yellow 
        puts 'You may be prompted for the production password.'.yellow if Rails.env == 'production'

        database = ActiveRecord::Base.connection.current_database
        path     = File.join(@args[:backup_directory], Time.now.utc.strftime('%Y-%m-%d_%H%M%S%Z') + '.dump')

        puts "Dumping #{database} to #{path}".yellow
        puts(Benchmark.measure { `pg_dump --username=#{ENV["db_user"]} --host=localhost --format=custom #{database} --file=#{path}` })
        raise "pg_dump failed with exit code #{$?.to_i}".red unless $? == 0
        puts 'Dump complete'.yellow

        raise 'Failed to create dump file'.red unless File.exists?(path)

      else
        puts "Dump for #{Rails.env} environment failed, database does not exist.".red
      end
    end

    # There are at least 1) failure cases when using restore_last:
    # 1)  drop fails because database is in use by other processes.
    #       Remedy: Ensure your database is not used by other processes. Check to see how many connections to the database exist.
    # 
    desc 'Dump the data as a backup, then restore the db from the specified file.'
    task :restore => [:dump, 'db:drop', 'db:create' ] do 

      # TODO: NEED TO DIE IF *RAILS* (server) IS RUNNING

      puts "Initializing restore for #{Rails.env} environment".yellow 
      raise 'Specify a dump file: rake tw:db:restore file=myfile.dump'.yellow if not ENV['file']

      database = ActiveRecord::Base.connection.current_database

      path = File.join(@args[:backup_directory], ENV["file"])
      puts "Restoring #{database} from #{path}".yellow

      puts(Benchmark.measure { `pg_restore --username=#{ENV["db_user"]} --host=localhost --format=custom --disable-triggers --dbname=#{database} #{path}` })
      raise "pg_restore failed with exit code #{$?.to_i}".red unless $? == 0

      # TODO: Once RAILS is restarted automagically this this can go
      reset_indecies
    end

    desc 'Restore from youngest dump file. Handy!'
    task :restore_last => [:find_last, :restore] do
      puts "Restoring from #{ENV['file']}".yellow
      reset_indecies
    end

    task :find_last => [:environment, :backup_directory] do
      file = Dir[File.join(@args[:backup_directory], '*.dump')].sort.last
      raise 'No dump has been found' unless file
      ENV['file'] = File.basename(file)
    end

    task :db_user => [:environment] do
      ENV['db_user'] = Rails.configuration.database_configuration[Rails.env]['username'] if ENV['db_user'].blank?
    end

    private 

    # This should just be done by restarting the server and making a new connection!
    def reset_indecies
      puts 'Resetting AR indecies.' 
      ActiveRecord::Base.connection.tables.each { |t| ActiveRecord::Base.connection.reset_pk_sequence!(t) }
      puts 'Restore complete'
    end
  end
end
