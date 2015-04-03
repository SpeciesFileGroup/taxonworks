require 'rake'
require 'benchmark'
=begin
 Schema |                          Name                          | Type  |         Owner
--------+--------------------------------------------------------+-------+------------------------
 public | users                                                  | table | taxonworks_development
 public | projects                                               | table | taxonworks_development
 public | otus                                                   | table | taxonworks_development
 public | asserted_distributions                                 | table | taxonworks_development
 public | biocuration_classifications                            | table | taxonworks_development
 public | biological_associations                                | table | taxonworks_development
 public | biological_associations_biological_associations_graphs | table | taxonworks_development
 public | biological_associations_graphs                         | table | taxonworks_development
 public | biological_relationship_types                          | table | taxonworks_development
 public | biological_relationships                               | table | taxonworks_development
 public | citation_topics                                        | table | taxonworks_development
 public | collecting_events                                      | table | taxonworks_development
 public | collection_objects                                     | table | taxonworks_development
 public | collection_profiles                                    | table | taxonworks_development
 public | container_items                                        | table | taxonworks_development
 public | container_labels                                       | table | taxonworks_development
 public | containers                                             | table | taxonworks_development
 public | contents                                               | table | taxonworks_development
 public | controlled_vocabulary_terms                            | table | taxonworks_development
 public | geographic_area_types                                  | table | taxonworks_development
 public | geographic_areas                                       | table | taxonworks_development
 public | geographic_items                                       | table | taxonworks_development
 public | georeferences                                          | table | taxonworks_development
 public | images                                                 | table | taxonworks_development
 public | imports                                                | table | taxonworks_development
 public | languages                                              | table | taxonworks_development
 public | loan_items                                             | table | taxonworks_development
 public | loans                                                  | table | taxonworks_development
 public | namespaces                                             | table | taxonworks_development
 public | otu_page_layout_sections                               | table | taxonworks_development
 public | otu_page_layouts                                       | table | taxonworks_development
 public | people                                                 | table | taxonworks_development
 public | pinboard_items                                         | table | taxonworks_development
 public | preparation_types                                      | table | taxonworks_development
 public | project_members                                        | table | taxonworks_development
 public | project_sources                                        | table | taxonworks_development
 public | public_contents                                        | table | taxonworks_development
 public | ranged_lot_categories                                  | table | taxonworks_development
 public | repositories                                           | table | taxonworks_development
 public | roles                                                  | table | taxonworks_development
 public | serial_chronologies                                    | table | taxonworks_development
 public | serials                                                | table | taxonworks_development
 public | sources                                                | table | taxonworks_development
 public | spatial_ref_sys                                        | table | taxonworks_development
 public | tagged_section_keywords                                | table | taxonworks_development
 public | taxon_determinations                                   | table | taxonworks_development
 public | taxon_name_classifications                             | table | taxonworks_development
 public | taxon_name_relationships                               | table | taxonworks_development
 public | taxon_names                                            | table | taxonworks_development
 public | test_classes                                           | table | taxonworks_development
 public | type_materials                                         | table | taxonworks_development
 public | versions                                               | table | taxonworks_development

 public | alternate_values                                       | table | taxonworks_development
 public | citations                                              | table | taxonworks_development
 public | data_attributes                                        | table | taxonworks_development
 public | identifiers                                            | table | taxonworks_development
 public | notes                                                  | table | taxonworks_development
 public | tags                                                   | table | taxonworks_development

List of classes which are dependant on the existence of other objects
  alternate values
  citations
  data attributes
  identifiers
  notes
  tags

Deliberately excluded:
public | schema_migrations                                      | table | taxonworks_development

=end

TABLE_NAMES = %w{users
                projects
                otus
                asserted_distributions
                biocuration_classifications
                biological_associations
                biological_associations_biological_associations_graphs
                biological_associations_graphs
                biological_relationship_types
                biological_relationships
                citation_topics
                collecting_events
                collection_objects
                collection_profiles
                container_items
                container_labels
                containers
                contents
                controlled_vocabulary_terms
                geographic_area_types
                geographic_areas
                geographic_items
                geographic_areas_geographic_items
                georeferences
                images
                imports
                languages
                loan_items
                loans
                namespaces
                otu_page_layout_sections
                otu_page_layouts
                people
                pinboard_items
                preparation_types
                project_members
                project_sources
                public_contents
                ranged_lot_categories
                repositories
                roles
                serial_chronologies
                serials
                sources
                spatial_ref_sys
                tagged_section_keywords
                taxon_determinations
                taxon_name_classifications
                taxon_name_relationships
                taxon_names
                test_classes
                type_materials
                versions
                alternate_values
                citations
                data_attributes
                identifiers
                notes
                tags}

namespace :tw do
  namespace :db do
    desc "Dump the data to a PostgreSQL custom-format dump file"
    task :dump => [:environment, :data_directory, :db_user] do
      database = ActiveRecord::Base.connection.current_database
      path     = File.join(@args[:data_directory], Time.now.utc.strftime("%Y-%m-%d_%H%M%S%Z") + '.dump')

      puts "Dumping database to #{path}"
      puts(Benchmark.measure { `pg_dump -U #{ENV["db_user"]} -Fc #{database} --data-only -f #{path}` })
      raise "pg_dump failed with exit code #{$?.to_i}" unless $? == 0
      puts "Dump complete"

      raise "Failed to create dump file" unless File.exists?(path)
    end

    desc "Dump the data as a backup, then restore the db from the specified file."
    task :restore => [:dump, :environment, :data_directory, :db_user] do
      raise "Specify a dump file: rake tw:db:restore file=myfile.dump" if not ENV["file"]
      database = ActiveRecord::Base.connection.current_database
      path     = File.join(@args[:data_directory], ENV["file"])
      puts "Restoring database from #{path}"
      puts(Benchmark.measure { `pg_restore -U #{ENV["db_user"]} -Fc -c -d #{database} #{path}` })
      raise "pg_restore failed with exit code #{$?.to_i}" unless $? == 0
      puts "Restore complete"
    end

    desc "Restore from youngest dump file. Handy!"
    task :restore_last => [:find_last, :restore]

    task :find_last => [:environment, :data_directory] do
      file = Dir[File.join(@args[:data_directory], '*.dump')].sort.last
      raise "No dump has been found" unless file
      ENV["file"] = File.basename(file)
    end

    task :db_user => [:environment] do
      ENV["db_user"] = Rails.configuration.database_configuration[Rails.env]["username"] if ENV["db_user"].blank?
    end

    desc '(not ready) Restore tables in the proper order. (Hard-coded)'
    task :ordered_restore => [:environment] do
      database_name = ActiveRecord::Base.connection.current_database
      dump_filename = '/Users/tuckerjd/src/gaz/data/hand-built/dump/2015-04-02_132159UTC.dump'

      TABLE_NAMES.each { |table|
        puts table
        puts(Benchmark.measure { `pg_restore -Fc -c --data-only --disable-triggers -d #{database_name} -t #{table} #{dump_filename}` })

        # puts(Benchmark.measure { Support::Database.pg_restore(database, "#{table}", '/Users/tuckerjd/src/gaz/data/hand-built/dump/2015-04-02_132159UTC.dump') })
      }

    end
  end
end
