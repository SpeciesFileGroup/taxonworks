require 'rake'

namespace :tw do
  namespace :db do

    desc 'Dump the data to a PostgreSQL custom-format dump file does NOT include structure'
    task :dump => [:environment, :backup_directory, :db_user] do
      if Support::Database.pg_database_exists?
        puts Rainbow("Initializing dump for #{Rails.env} environment").yellow 
        puts Rainbow('You may be prompted for the production password.').yellow if Rails.env == 'production'

        database = ActiveRecord::Base.connection.current_database
        path  = File.join(@args[:backup_directory], Time.now.utc.strftime('%Y-%m-%d_%H%M%S%Z') + '.dump')

        puts Rainbow("Dumping #{database} to #{path}").yellow
        puts(Benchmark.measure { `pg_dump --username=#{ENV["db_user"]} --host=localhost --format=custom #{database} --file=#{path} -Ft` })
        raise TaxonWorks::Error, "pg_dump failed with exit code #{$?.to_i}".red unless $? == 0
        puts Rainbow('Dump complete').yellow

        raise TaxonWorks::Error, Rainbow('Failed to create dump file').red unless File.exists?(path)

      else
        puts Rainbow("Dump for #{Rails.env} environment skipped, database does not exist.").red
      end
    end

    # There are at least 1) failure cases when using restore_last:
    # 1) Drop fails because database is in use by other processes.
    #    Remedy: Ensure your database is not used by other processes. Check to see how many connections to the database exist.
    #    Do not modify this task to make that check, nest this in checks if needed
    desc 'Restores the db from the specified file. Intended to be wrapped in other checks.'
    task :restore => ['tw:existing_file', 'db:drop', 'db:create' ] do 
      puts Rainbow("Initializing restore for #{Rails.env} environment").yellow 
      database = ActiveRecord::Base.connection.current_database
      path = File.join(@args[:backup_directory], ENV['file'])
      puts Rainbow("Restoring #{database} from #{path}").yellow

      puts(Benchmark.measure{ `pg_restore --username=#{ENV["db_user"]} --host=localhost --format=custom --no-acl --disable-triggers --dbname=#{database} #{path}` })
      raise TaxonWorks::Error, Rainbow("pg_restore failed with exit code #{$?.to_i}").red unless $? == 0

      # TODO: Once RAILS is restarted automagically this this can go
      reset_indecies
    end

    desc 'First dump then restore the database. Not intended for Production uses.'
    task :safe_restore => [:dump, :restore]

    desc 'Restore from youngest dump file. Handy!'
    task :restore_last => [:find_last, :restore] do
      puts Rainbow("Restoring from #{ENV['file']}").yellow
      reset_indecies
    end

    task :find_last => [:environment, :backup_directory] do
      file = Dir[File.join(@args[:backup_directory], '*.dump')].sort.last
      raise TaxonWorks::Error, 'No dump has been found' unless file
      ENV['file'] = File.basename(file)
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
