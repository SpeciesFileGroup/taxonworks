require 'rake'

namespace :tw do
  namespace :db do

    def postgres_arguments(hsh = {})
      hsh.select!{|k,v| !v.nil?}
      hsh.collect{|k,v| "#{k}=#{v}"}.join(' ') 
    end

    desc 'Dump the data to a PostgreSQL custom-format dump file does NOT include structure'
    task :dump => [:environment, :backup_directory, :database_host, :database_user] do
      if Support::Database.pg_database_exists?
        puts Rainbow("Initializing dump for #{Rails.env} environment").yellow 
        puts Rainbow('You may be prompted for the production password, alternately set it in ~/.pgpass').yellow if Rails.env == 'production'

        database = ActiveRecord::Base.connection.current_database
        path  = File.join(@args[:backup_directory], Time.now.utc.strftime('%Y-%m-%d_%H%M%S%Z') + '.dump')

        puts Rainbow("Dumping #{database} to #{path}").yellow

        # "--username=#{@args[:database_user]} --host=#{@args[:database_host]} --format=custom #{database} --file=#{path}"
        args = postgres_arguments(
          {
            '--format' => 'custom',
            '--file' => path,
            '--username' => @args[:database_user],
            '--host' => @args[:database_host],
          }
        )

        args = args + " #{database}"

        puts Rainbow("with arguments: #{args}").yellow
        puts(Benchmark.measure { `pg_dump #{args}` })
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
    desc "Restores a database generated from dump 'rake tw:db:restore backup_directory=/your/path/ file=2017-07-10_154344UTC.dump'" 
    task :restore => ['environment', 'tw:backup_exists', 'tw:database_user', 'db:drop', 'db:create' ] do 
      puts Rainbow("Initializing restore for #{Rails.env} environment").yellow 
      database = ActiveRecord::Base.connection.current_database
      puts Rainbow("Restoring #{database} from #{@args[:tw_backup_file]}").yellow

      args = postgres_arguments(
        {
          '--format' => 'custom',
          '--dbname' => database,
          '--username' => @args[:database_user],
          '--host' => @args[:database_host],
        }
      )

      args += " --no-acl --disable-triggers #{@args[:tw_backup_file]}" 

      puts Rainbow("with arguments: #{args}").yellow

      puts(Benchmark.measure{ `pg_restore #{args}` })
      raise TaxonWorks::Error, Rainbow("pg_restore failed with exit code #{$?.to_i}").red unless $? == 0

      # TODO: Once RAILS is restarted automagically this this can go
      reset_indecies
    end

    desc 'First dump then restore the database. Not intended for Production uses.'
    task :safe_restore => [:dump, :restore]

    desc 'Restore from youngest dump file. Handy!'
    task :restore_last => [:set_restore_to_last_file, :restore] do
      puts Rainbow("Restoring from #{@args[:file]}").yellow
      reset_indecies
    end

    task :set_restore_to_last_file => [:find_last] do
      # Set the file by finding it, rather than through the ENV
      Rake.application['tw:backup_exists'].prerequisites.delete('file')
    end

    task :find_last => [:environment, :backup_directory] do
      file = Dir[File.join(@args[:backup_directory], '*.dump')].sort.last
      raise TaxonWorks::Error, Rainbow("No dump has been found in #{@args[:backup_directory]}").red unless file
      @args[:file] = File.basename(file)
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
