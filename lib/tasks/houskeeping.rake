# We'll add foreign keys with immigrant ultimately
# https://github.com/jenseng/immigrant

require 'fileutils'

namespace :tw do
  namespace :development do
    desc 'generate housekeeping migration for all models with housekeeping concern'
    task  :generate_housekeeping_migration =>  [:environment] do |t|

      # Ensure that we have all models loaded
      Rails.application.eager_load!

      mf =  File.new(Rails.root + 'tmp/migration.tmp', 'w')

      puts "# known subclasses of ActiveRecord::Base  #{ActiveRecord::Base.subclasses.collect{|a| a.name}.sort.join(", ")} \n"

      migrated, not_migrated = [], []
      ActiveRecord::Base.subclasses.each do |d|
        hit = false
        if d.ancestors.include?(Housekeeping::Users)
          hit = true
          puts "add_column :#{d.name.demodulize.underscore}s, :created_by_id, :integer, index: true"  
          puts "add_column :#{d.name.underscore}s, :updated_by_id, :integer, index: true"  
        end

        if d.ancestors.include?(Housekeeping::Projects) 
          hit = true
          puts "add_column :#{d.name.underscore}s, :project_id, :integer, index: true"  
        end

         hit ? migrated.push(d.name) : not_migrated.push(d.name)
      end
      puts "# -----------\n\n # migrated: #{migrated.join(', ')} \n\n # not_migrated: #{not_migrated.join(", ")}"
    end

  end
end
