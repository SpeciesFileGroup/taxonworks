namespace :tw do
  require_relative 'support/database'

  task :fail do
    raise
  end

  task :pass do
    true
  end

  task :check_for_database do
    raise TaxonWorks::Error, "can not attach to database" unless Support::Database.pg_database_exists?
  end

  task :db_user => [:environment] do
    @args[:db_user] = Rails.configuration.database_configuration[Rails.env]['username'] if ENV['db_user'].blank?
  end

  desc 'Sets $user_id via "user_id=1" option. checks to see it exists.'
  task :user_id => [:environment] do
    raise "You must specify a user_id like 'user_id=2'" unless ENV["user_id"]
    raise "User #{ENV['user_id']} doesn't exist." if !User.find(ENV["user_id"])
    $user_id = ENV["user_id"].to_i
  end

  desc 'Sets $project_id via "project_id=1" option. checks to see it exists.'
  task :project_id => [:environment] do
    raise "You must specify a project_id like 'project_id=1" unless ENV["project_id"]
    raise "Project #{ENV['project_id']} doesn't exist." if !Project.find(ENV["project_id"])
    $project_id = ENV["project_id"].to_i
  end

  desc 'Sets $table_name via "table_name=taxon_names" option.'
  task :table_name do
    raise "You must specify a table_name like 'table_name=collection_objects" unless ENV['table_name']
    $table_name = ENV['table_name']
  end

  desc 'Require both user_id and project_id.'
  task :with_user_and_project => [:environment, :user_id, :project_id] do
    raise "User is not a member of project." if !ProjectMember.where(project_id: $project_id, user_id: $user_id)
  end

  desc 'a default method to add a data_directory_argument, include trailing slash'
  task  :data_directory => [:environment] do 
    default = Settings.default_data_directory
    @args ||= {} 
    if ENV['data_directory'].blank?
      if default
        puts "no data_directory passed, using default (#{default})"
      else
        raise "no data_directory passed (like data_directory=/tmp/foo) and default_data_directory setting is not present (see application_settings.yml in /config)"
      end
    end
    @args.merge!(data_directory: (ENV['data_directory'] || default ))
    raise "path (#{default}) not found" if !File.exists?(@args[:data_directory]) # TODO: Use Dir.exists? and fix tasks that are treating data_directory as a file parameter
    @args
  end

  desc 'a default task to add a backup_directory_argument, include trailing slash'
  task  :backup_directory => [:environment] do 
    default = Settings.backup_directory
    @args ||= {} 
    if ENV['backup_directory'].blank?
      if default
        puts "No backup_directory passed, using default (#{default})"
      else
        raise "No backup_directory passed (like backup_directory=/tmp/foo) and backup_directory setting is not present (see application_settings.yml in /config)"
      end
    end
   
    @args[:backup_directory] = (ENV['backup_directory'] || default )

    raise "path (#{@args[:backup_directory]}) not found" if !Dir.exists?(@args[:backup_directory]) 
    @args
  end

  desc 'a general purpose task to supply a file @args, file=file.txt' 
  task :file do
    file = ENV['file']
    raise TaxonWorks::Error, Rainbow('Specify a file, like file=myfile.dump').yellow if not ENV['file']
    @args ||= {}
    @args[:file] = file
  end

  desc 'provide file=/foo/something.bar and ensure file exists with provided value'
  task :existing_file => [:file] do
    raise TaxonWorks::Error, "Provided file (#{@args[:file]}) does not exist." unless File.exists?(@args[:file])
  end

  task :backup_exists => [:file, :backup_directory] do
    path = File.join(@args[:backup_directory], @args[:file])
    raise TaxonWorks::Error, "Provided file (#{path}) does not exist." unless File.exists?(path)
    @args[:tw_backup_file] = path
  end

  desc 'set the database_role ENV value if provided, or use "postgres"'
  task  :database_role do |t| 
    @args ||= {}
    @args.merge!(database_role: (ENV['database_role'] || 'postgres'))
  end

  # General purpose table related

  # True if the table exists in the present environment's database
  def table_exists(table_name)
    ActiveRecord::Base.connection.execute("SELECT EXISTS(SELECT * FROM information_schema.tables WHERE table_name = '#{table_name}');").first['exists'] == 't'
  end

end

