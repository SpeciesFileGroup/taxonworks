namespace :tw do
  namespace :project_import do
    namespace :sf_import do

      desc 'time rake tw:project_import:sf_import:run_all_import_tasks user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
      task :run_all_import_tasks => [
       #  'start:create_users',
       #  'start:create_people',
       #  'start:map_serials',
       #  'start:map_pub_type',
       #  'start:map_ref_links',
       #  'start:list_verbatim_refs',
       #  'start:create_projects',
       #  'start:create_sources',
       #  'start:create_source_editor_array',
       #  'start:create_source_roles',
       #  'start:create_sf_book_hash',
       #  'start:update_sources_with_booktitle_publisher_address',

       #  'taxa:create_rank_hash',
       #  'taxa:create_animalia_below_root',
       #  'taxa:create_sf_synonym_id_to_new_parent_id_hash',
       #  'taxa:create_otus_for_ill_formed_names_hash',
       #  'taxa:create_all_sf_taxa_pass1',
       #  'taxa:create_type_species',
       #  'taxa:create_type_genera',
       #  'taxa:create_some_related_taxa',
       #  'taxa:create_status_flag_relationships',

       #  'cites:import_nomenclator_strings',
          'cites:create_cvts_for_citations',
          'cites:create_citations'
      ] do
        puts 'Ran all import tasks!'
      end
    end
  end
end


=begin
List of error logs user should fix:

Rake task, kind of error, file or project id [instances]

:create_some_related_taxa
  - OlderNameID = YoungerNameID ("Object taxon name Taxon should not refer to itself"), FileID = 1, 8, 11, 14, 56 [56 instances]
  - Suppressed older or younger name, probably OTU was created for ill-formed name, FileID = unknown for suppressions [45 instances]

:create_status_flag_relationships
  - 234 failed attempts to create TaxonNameRelationships, mostly due to rank issues
  - Created note for each failure detailing SF status flag value, attempted relationship, error message




=end
