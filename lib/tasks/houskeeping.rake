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

      puts "# known subclasses of ActiveRecord::Base  #{ActiveRecord::Base.subclasses.collect{|a| a.name}.join(", ")}"

      ActiveRecord::Base.subclasses.each do |d|
        if d.ancestors.include?(Housekeeping::Users)
          puts "add_column :#{d.name.demodulize.underscore}s, :created_by_id, :integer, index: true"  
          puts "add_column :#{d.name.underscore}s, :updated_by_id, :integer, index: true"  
        end

        if d.ancestors.include?(Housekeeping::Projects) 
          puts "add_column :#{d.name.underscore}s, :project_id, :integer, index: true"  
        end
      end
    end

  end
end
