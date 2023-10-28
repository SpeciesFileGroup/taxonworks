require 'io/console'

namespace :tw do

  # Tasks for initializing a new (usually production) version of TaxonWorks
  #  We are intentionally not using the seed functionality.
  namespace :initialize do
    desc "create an administrator, and set ENV['user_id'] to that users id if successfull"
    task create_administrator: [:environment] do |t|
      puts 'add an administrator: '
      print 'email: '
      email = STDIN.gets.strip
      print 'name: '
      name = STDIN.gets.strip
      print 'password: '
      password = STDIN.noecho(&:gets).strip
      puts
      print 'confirm password: '
      password_confirmation = STDIN.noecho(&:gets).strip
      puts

      u = User.create!(name:,
                      email:,
                      password:,
                      password_confirmation:,
                      is_administrator:      true,
                      self_created:          true)

      if u.valid?
        ENV['user_id'] = u.to_param
        puts "Successfully created TaxonWorks administrator #{name}."
      else
        raise "Failed to create TaxonWorks administrator (#{u.errors.messages})."
      end
    end

    task check_for_clean_database: [:environment] do |t|
      # Rails.application.eager_load!
      errored = false
      ApplicationRecord.descendants.each do |klass|
        puts "#{klass.name}"
        if klass.count > 0
          puts "#{klass.name} has records".red
          errored = true
        end
      end

      if errored
        puts 'Database has some existing data!'.red
        raise
      else
        puts 'Database *appears* empty.'.yellow
      end

    end

    task check_for_initialization_data: [:environment, :data_directory] do |t|
      manifest = %w{
       ISO-639-2_utf-8.txt
       biorepositories.csv
       geographic_area_types.dump
       geographic_areas.dump
       geographic_areas_geographic_items.dump
       geographic_items.dump
       serial_table.dump
       serial_metadata_tables.dump
      }

      puts "\nChecking for initialization data."

      errored = false
      manifest.each do |f|
        file = @args[:data_directory] + f
        if File.exist?(file)
          puts "found #{f}"
        else
          errored = true
          puts "missing #{file}".red
        end
      end
      if errored
        puts 'Initialization missing data!'.red
        raise
      else
        puts 'Found all required files.'.yellow
      end
    end

    task validate_initialization: [:environment] do
      errors = false
      # TODO: have @tuckerjd sanity check this list, is something missing from Geo?
      [Serial, SerialChronology, Identifier, DataAttribute, AlternateValue,
       GeographicItem, GeographicAreaType, GeographicArea, GeographicAreasGeographicItem,
       Language, Repository].each do |klass|
        if klass.count > 0
          puts "Found #{klass.name.pluralize}.".yellow
        else
          errors = true
          puts "Could not find #{klass.name.pluralize}.".red
        end
      end
      if errors
        puts '!! There were errors on initialization !!'.red
        raise
      end
    end


    # users.yml uses the pattern:
    #
    # email:
    #   attribute: value
    #   ...
    #
    # ---
    # test@example.com:
    #    :password: some_long_password
    #    :is_administrator: true
    #    :name: smith
    #
    task validate_users: [:environment, :data_directory] do
      file      = @args[:data_directory] + 'users.yml'
      user_data = {}

      print 'Checking for users.yml ...'
      if File.exist?(file)
        print "found, validating.\n"
        user_data = YAML.load_file(file)
      else
        print "not found, skipping.\n"
        next
      end

      user_data.each do |k, v|
        attributes = v.merge(email: k, self_created: true)
        u          = User.new(attributes)
        unless u.valid?
          puts "Invalid user in users.yml: #{attributes}. #{u.errors.full_messages.join(' ')}".red
          exit
        end
      end
      puts 'Users in users.yml are valid.'.yellow
    end

    desc 'Load users from users.yml - rake tw:initialize:load_users data_directory=/path/to/file/'
    task load_users: [:environment, :data_directory, :validate_users] do
      file      = @args[:data_directory] + 'users.yml'
      user_data = {}
      users     = []
      if File.exist?(file)
        user_data = YAML.load_file(file)
        begin
          User.transaction do |t|
            user_data.each do |k, v|
              attributes = v.merge(email: k, self_created: true)
              users.push User.create!(attributes)
            end
          end
        rescue
          raise
        end
      end
      puts "#{users.length} users loaded.".yellow
    end

    desc 'Fully initialize a production server'
    task all: [
                :environment,
                :check_for_clean_database,
                :check_for_initialization_data,
                :validate_users,
                :create_administrator,
                :load_users,
                :load_repositories,
                :load_languages,
                :load_geo,
                :load_serials,
                :validate_initialization
              ] do
      puts 'Success! Welcome to TaxonWorks.'.yellow
    end


  end
end
