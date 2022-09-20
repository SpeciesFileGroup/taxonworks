require 'fileutils'

namespace :tw do
  task :fail do
    raise
  end

  task :pass do
    true
  end

  task server_name: [:environment] do
    @args ||= {}
    n = @args[:server_name]
    n ||= (ENV['database_host'] || 'localhost')
    @args[:server_name] = n
  end

  task :check_for_database do
    raise TaxonWorks::Error, 'can not attach to database' unless Support::Database.pg_database_exists?
  end

  # TODO: update "database_user" to something more specific and reflective of what we see in Kubernetes by default?
  task database_user: [:environment] do
    @args ||= {}
    @args[:database_user] = ENV['database_user']
    @args[:database_user] ||= Rails.configuration.database_configuration[Rails.env]['username']
  end

  desc 'set the database_host to ENV of database_host or use "0.0.0.0"'
  task :database_host do |t|
    @args ||= {}
    @args[:database_host] = ENV['database_host']
    @args[:database_host] ||= Rails.configuration.database_configuration[Rails.env]['host'] || '0.0.0.0'
  end

  desc 'Sets Current.user_id via "user_id=1" option. checks to see it exists.'
  task user_id: [:environment] do
    raise "You must specify a user_id like 'user_id=2'" unless ENV['user_id']
    raise "User #{ENV['user_id']} doesn't exist." if !User.find(ENV['user_id'])
    Current.user_id = ENV['user_id'].to_i
    @args ||= {}
    @args[:user_id] = Current.user_id
  end

  desc 'Sets Current.project_id via "project_id=1" option. checks to see it exists.'
  task project_id: [:environment] do
    raise "You must specify a project_id like 'project_id=1" unless ENV['project_id']
    raise "Project #{ENV['project_id']} doesn't exist." if !Project.find(ENV['project_id'])
    Current.project_id =  ENV['project_id'].to_i
    @args ||= {}
    @args[:project_id] = Current.project_id
  end

  # TODO: Use Current
  desc 'Sets $table_name via "table_name=taxon_names" option.'
  task :table_name do
    raise "You must specify a table_name like 'table_name=collection_objects" unless ENV['table_name']
    $table_name = ENV['table_name']
  end

  desc 'Require both user_id and project_id.'
  task with_user_and_project: [:environment, :user_id, :project_id] do
    raise 'User is not a member of project.' if !ProjectMember.where(project_id: Current.project_id, user_id: Current.user_id)
  end

  desc 'a default method to add a data_directory_argument, include trailing slash'
  task data_directory: [:environment] do
    default = Settings.default_data_directory
    @args ||= {}
    if ENV['data_directory'].blank?
      if default
        puts "no data_directory passed, using default (#{default})"
      else
        raise 'no data_directory passed (like data_directory=/tmp/foo) and default_data_directory setting is not ' \
          'present (see application_settings.yml in /config)'
      end
    end
    @args.merge!(data_directory: (ENV['data_directory'] || default))
    # TODO: Use Dir.exists? and fix tasks that are treating data_directory as a file parameter
    raise Rainbow("Path to data directory (#{default}) not found").red if !File.exists?(@args[:data_directory])
    @args
  end

  desc 'a default task to add a backup_directory_argument, include trailing slash'
  task backup_directory: [:environment] do
    default = Settings.backup_directory
    @args ||= {}
    if ENV['backup_directory'].blank?
      if default
        puts "No backup_directory passed, using default (#{default})"
      else
        raise 'No backup_directory passed (like backup_directory=/tmp/foo) and backup_directory setting is not ' \
          'present (see application_settings.yml in /config)'
      end
    end

    @args[:backup_directory] = (ENV['backup_directory'] || default)

    if ENV['create_backup_directory'] == 'true'
      FileUtils.mkdir_p @args[:backup_directory]
    end

    raise "path (#{@args[:backup_directory]}) not found" if !Dir.exists?(@args[:backup_directory])

    @args
  end

  desc 'a general purpose task to supply a file @args, file=file.txt'
  task :file do
    raise TaxonWorks::Error, Rainbow('Specify a file, like file=myfile.dump').yellow if not ENV['file']
    @args ||= {}
    @args[:file] = ENV['file']
  end

  desc 'a general purpose task to supply a id in a range to @args, id_start=1'
  task :id_start do
    raise TaxonWorks::Error, Rainbow('Specify a minimum id, like id_start=123').yellow if not ENV['id_start']
    @args ||= {}
    @args[:id_start] = ENV['id_start'].to_i
  end

  desc 'a general purpose task to supply a id in a range to @args, id_end=1'
  task :id_end do
    raise TaxonWorks::Error, Rainbow('Specify a maximum id, like id_end=123').yellow if not ENV['id_end']
    @args ||= {}
    @args[:id_end] = ENV['id_end'].to_i
  end

  desc 'provide file=/foo/something.bar and ensure file exists with provided value'
  task existing_file: [:file] do
    raise TaxonWorks::Error, "Provided file (#{@args[:file]}) does not exist." unless File.exists?(@args[:file])
  end

  task backup_exists: [:file, :backup_directory] do
    path = File.join(@args[:backup_directory], @args[:file])
    raise TaxonWorks::Error, "Provided file (#{path}) does not exist." unless File.exists?(path)
    @args[:tw_backup_file] = path
  end

  desc 'set the database_role ENV value if provided, or use "postgres"'
  task :database_role do |t|
    @args ||= {}
    @args.merge!(database_role: (ENV['database_role'] || 'postgres'))
  end

  # General purpose table related

  # True if the table exists in the present environment's database
  def table_exists(table_name)
    ApplicationRecord.connection
      .execute("SELECT EXISTS(SELECT * FROM information_schema.tables " \
               "WHERE table_name = '#{table_name}');").first['exists'] == 't'
  end

end

