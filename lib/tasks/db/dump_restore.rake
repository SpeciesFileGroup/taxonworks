require 'rake'
require 'securerandom'

namespace :tw do
  namespace :db do

    def postgres_arguments(hsh = {})
      hsh.select!{|k,v| !v.nil?}
      hsh.collect{|k,v| "#{k}=#{v}"}.join(' ')
    end

    desc 'Remove all connections but the current one'
    task drop_connections: [:environment] do
      ApplicationRecord.connection.execute(
        "SELECT pg_terminate_backend(pg_stat_activity.pid)
        FROM pg_stat_activity
        WHERE pg_stat_activity.datname = 'TARGET_DB'
        AND pid <> pg_backend_pid();"
      )
    end

    desc 'Dump the data to a PostgreSQL custom-format dump file does NOT include structure'
    task dump: [:environment, :backup_directory, :server_name, :database_host, :database_user] do
      if Support::Database.pg_database_exists?
        puts Rainbow("Initializing dump for #{Rails.env} environment").yellow
        if Rails.env == 'production'
          puts Rainbow('You may be prompted for the production password, alternately set it in ~/.pgpass').yellow
        end

        database = ApplicationRecord.connection.current_database
        path  = File.join(@args[:backup_directory], [  SecureRandom.hex(8), @args[:server_name], Time.now.utc.strftime('%Y-%m-%d_%H%M%S%Z')].join('_') + '.dump')

        puts Rainbow("Dumping #{database} to #{path}").yellow

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
    desc "Restores a database generated from dump 'rake tw:db:restore backup_directory=/your/path/ database_host=0.0.0.0 file=2017-07-10_154344UTC.dump'"
    task restore: [:environment, :backup_exists, :database_user, :database_host, 'db:drop', 'db:create'] do
      puts Rainbow("Initializing restore for #{Rails.env} environment").yellow
      database = ApplicationRecord.connection.current_database
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

    desc "Drops, recreates and loads DB with data from a SQL file 'rake tw:db:load file=/your/path/dump.sql'"
    task load: [:environment, 'tw:file', 'db:drop', 'db:create'] do
      puts Rainbow("Initializing restore for #{Rails.env} environment").yellow
      database = ApplicationRecord.connection.current_database
      puts Rainbow("Restoring #{database} from #{@args[:file]}").yellow

      config = Support::Database.pg_env_args

      system(config[:env], 'psql', '-v', 'ON_ERROR_STOP=1', *config[:args], '-f', @args[:file])
      raise TaxonWorks::Error, Rainbow("psql failed with exit code #{$?.to_i}").red unless $? == 0
    end

    desc 'First dump then restore the database. Not intended for Production uses.'
    task safe_restore: [:dump, :restore]

    desc 'Restore from youngest dump file. Handy!'
    task restore_last: [:set_restore_to_last_file, :restore] do
      puts Rainbow("Restoring from #{@args[:file]}").yellow
      reset_indecies
    end

    task set_restore_to_last_file: [:find_last] do
      # Set the file by finding it, rather than through the ENV
      Rake.application['tw:backup_exists'].prerequisites.delete('file')
    end

    task find_last: [:environment, :backup_directory] do
      file = Dir[File.join(@args[:backup_directory], '*.dump')].sort{|a,b| file_name_timestamp(a) <=> file_name_timestamp(b)}.last
      puts Rainbow("Last dump found: #{file}").purple
      raise TaxonWorks::Error, Rainbow("No dump has been found in #{@args[:backup_directory]}").red unless file
      @args[:file] = File.basename(file)
    end

    private

    def file_name_timestamp(filename)
      filename.match(/.?_(\d\d\d\d.*).dump$/)[1].to_s
    end

    # This should just be done by restarting the server and making a new connection!
    def reset_indecies
      puts 'Resetting AR indecies.'
      ApplicationRecord.connection.tables.each { |t| ApplicationRecord.connection.reset_pk_sequence!(t) }
      puts 'Restore complete'
    end
  end
end
