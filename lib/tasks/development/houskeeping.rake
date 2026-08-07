# We'll add foreign keys with immigrant ultimately
# https://github.com/jenseng/immigrant

require 'fileutils'

namespace :tw do
  namespace :development do
    desc 'generate housekeeping migration for all models with housekeeping concern'
    task  generate_housekeeping_migration: [:environment] do |t|

      # Ensure that we have all models loaded
      # Rails.application.eager_load!

      puts "# known subclasses of ApplicationRecord  #{ApplicationRecord.subclasses.collect{|a| a.name}.sort.join(", ")} \n"

      migrated, not_migrated = [], []
      ApplicationRecord.subclasses.sort{|a,b| a.name <=> b.name}.each do |d|
        hit = false
        if d.ancestors.include?(Housekeeping::Users)
          hit = true
          puts "add_column :#{d.name.demodulize.underscore.pluralize}, :created_by_id, :integer, index: true"
          puts "add_column :#{d.name.underscore.pluralize}, :updated_by_id, :integer, index: true"
        end

        if d.ancestors.include?(Housekeeping::Projects)
          hit = true
          puts "add_column :#{d.name.underscore.pluralize}, :project_id, :integer, index: true"
        end

        hit ? migrated.push(d.name) : not_migrated.push(d.name)
      end
      puts "# -----------\n\n # migrated: #{migrated.join(', ')} \n\n # not_migrated: #{not_migrated.join(", ")}"
    end


    desc 'generate not null template migration'
    task  generate_not_null_migration: [:environment] do |t|
      # Ensure that we have all models loaded
      # Rails.application.eager_load!

      migrated, not_migrated = [], []
      ApplicationRecord.subclasses.sort{|a,b| a.name <=> b.name}.each do |d|
        puts "# #{d.name}"
        d.columns.each do |c|
         # if c.name =~ /.+_id|.*_?type|position|type|name|created_at|updated_at/
          puts "# #{d.name}.connection.execute('alter table #{d.table_name} alter #{c.name} set not null;')"
         # end
        end
        puts "\n"
      end
    end


    desc 'generate index template migration'
    task  generate_index_migration: [:environment] do |t|
      # Ensure that we have all models loaded
      # Rails.application.eager_load!

      migrated, not_migrated = [], []
      ApplicationRecord.subclasses.sort{|a,b| a.name <=> b.name}.each do |d|
        puts "# #{d.name}"
        d.columns.each do |c|
          if c.name =~ /.+_id|.*_?type|position|type|lft|rgt|position/ # lft/rgt are not here any more
            puts "# add_index :#{d.table_name}, :#{c.name.to_sym}"
          end
        end
        puts "\n"
      end
    end

    desc 'generate fk template migration'
    task  generate_fk_migration: [:environment] do |t|
      # Ensure that we have all models loaded
      # Rails.application.eager_load!

      migrated, not_migrated = [], []
      ApplicationRecord.subclasses.sort{|a,b| a.name <=> b.name}.each do |d|
        puts "# #{d.name}"
        d.columns.each do |c|
          if c.name =~ /.+_id/
            puts "# #{d.name}.connection.execute('alter table #{d.table_name} add foreign key (#{c.name}) references CHANGE_ME (id);')"
          end
        end
        puts "\n"
      end
    end





  end
end
