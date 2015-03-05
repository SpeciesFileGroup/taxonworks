require 'io/console'

namespace :tw do

  # Tasks for initializing a new (usually production) version of TaxonWorks 
  #  We are inentionally not using the seed functionality. 
  namespace :initialize do
    desc "create an administrator, and set ENV['user_id'] to that users id if successfull"
    task :create_administrator => [:environment] do |t|
      puts "add an administrator: "
      print "email: "
      email = STDIN.gets.strip
      print "name: "
      name = STDIN.gets.strip
      print "password: "
      password = STDIN.noecho(&:gets).strip
      puts 
      print "confirm password: "
      password_confirmation = STDIN.noecho(&:gets).strip
      puts

      u = User.create(name: name, email: email, password: password, password_confirmation: password_confirmation, is_administrator: true, self_created: true)

      if u.valid?
        ENV["user_id"] = u.to_param
        puts "Successfully created TaxonWorks administrator #{name}."
      else
        raise "Failed to create TaxonWorks administrator (#{u.errors.messages})."
      end
    end

    task :check_for_clean_database => [:environment] do |t|
      Rails.application.eager_load!
      errored = false
      ActiveRecord::Base.descendants.each do |klass|
        if klass.count > 0
          puts "#{klass.name} has records".red 
          errored = true
        end
      end

      if errored
        puts "Database has some existing data!".red.on_white
        raise 
      else
        puts "Database *appears* empty.".bold
      end

    end

    task :check_for_initialization_data => [:environment, :data_directory] do |t|
      manifest = %w{
       ISO-639-2_utf-8.txt
       biorepositories.csv
       geographic_area_types.dump
       geographic_areas.dump
       geographic_areas_geographic_items.dump
       geographic_items.dump
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
        puts "Initialization missing data!".red.on_white
        raise 
      else
        puts "Found all required files.".bold
      end
    end
    
    task :all => [
      :environment,
      :check_for_clean_database,
      :check_for_initialization_data,
      :create_administrator,
      :load_repositories,
      :load_languages,
      :load_geo
    ] do 
      puts "Success! Welcome to TaxonWorks.".bold.yellow
    end

  end
end
