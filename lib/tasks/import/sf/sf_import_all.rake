namespace :tw do
  namespace :project_import do
    namespace :sf_import do

      # rake tw:db:restore backup_directory=../db_backup file=../db_backup/0_pristine_tw_init_all/2016-04-26_192513UTC.dump

      desc 'time rake tw:project_import:sf_import:run_all_import_tasks user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
      #  time rake tw:project_import:sf_import:run_all_import_tasks user_id=1 data_directory=/Users/sfg/src/onedb2tw/working/
      task run_all_import_tasks: [

          # 'tw:db:restore backup_directory=../db_backup file=../db_backup/0_pristine_tw_init_all/2016-04-26_192513UTC.dump',

          # ### start section took 419m54.488s
          # 'start:list_skipped_file_ids',
          #
          # 'start:create_users',
          # 'start:create_people',
          # 'start:map_serials',
          # 'start:map_ref_links',
          # 'start:list_verbatim_refs',
          # 'tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/1_after_verbatim_refs/',
          #
          # 'start:create_projects',
          # 'start:create_sf_book_hash',
          # 'start:map_pub_type',
          # 'start:create_sources',
          # 'tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/2_after_create_sources',
          #
          # 'start:create_source_editor_array',
          # 'start:create_source_roles',
          # 'tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/3_after_source_roles',
          #
          #
          # ### taxa section took 3929m23.113s
          # 'taxa:create_rank_hash',
          # 'taxa:create_animalia_below_root',
          # 'taxa:create_sf_synonym_id_to_new_parent_id_hash',
          # 'taxa:create_otus_for_ill_formed_names_hash',
          # 'tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/4_after_create_otus',
          #
          'taxa:create_all_sf_taxa_pass1',
          # 'tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/5_after_run_all_taxa',
          #
          # 'taxa:create_type_species',
          # 'taxa:create_type_genera',
          # 'tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/6_after_create_types',
          #
          # 'taxa:create_some_related_taxa',
          # 'tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/7_after_some_related_taxa',
          #
          # 'taxa:create_status_flag_relationships',
          # 'tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/8_after_status_flag_rels',
          #
          #
          # ### cites section took 423m23.501s
          # 'cites:import_nomenclator_strings',
          # 'cites:create_cvts_for_citations',
          # 'cites:create_sf_taxon_name_authors',
          # 'tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/9_after_taxon_authors',
          #
          # 'cites:create_citations',
          # 'tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/10_after_citations',
          #
          # 'cites:create_otu_cites',
          # 'tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/11_after_otu_cites',
          #
          #
          # ### specimens section took 195m28.611s
          # 'specimens:create_specimen_unique_id',
          # 'specimens:create_sf_geo_level4_hash',
          # 'tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/12_after_geo_level_4',
          #
          # 'specimens:collecting_events',
          # 'tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/13_after_coll_events',
          #
          # 'specimens:import_sf_depos',
          # 'tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/14_after_sf_depos',
          #
          # 'specimens:create_biocuration_classes',
          # 'tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/15_after_biocurations_classes',
          #
          # 'specimens:create_specimen_category_counts',
          # 'tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/16_after_specimen_counts',
          #
          # 'specimens:create_sf_source_metadata',
          # 'tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/17_after_source_metadata',
          #
          # 'specimens:create_sf_identification_metadata',
          # 'tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/18_after_identification_metadata',
          #
          # 'specimens:get_ident_qualifier_from_nomenclator',
          # 'tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/19_after_nomen_ident_qualifier',
          #
          # 'specimens:create_sf_loc_col_events_metadata',
          # 'specimens:collection_objects',
          # 'tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/20_after_collections_objects'
      
      ] do
        puts 'Ran all tasks!'
      end
    end
  end
end


=begin
Error logs:

[INFO]2018-02-08 22:38:35.433: Logged task tw:project_import:sf_import:taxa:create_all_sf_taxa_pass1 completed!
[INFO]2018-02-08 22:38:35.434: All tasks completed. Dumping summary for each task...
=== Summary of warnings and errors for task tw:project_import:sf_import:taxa:create_all_sf_taxa_pass1 ===
[WARN]2018-02-08 17:27:42.882: ALERT: Could not find parent_id of SF.TaxonNameID = 1221949 (error 1)! Set to animalia_id = 24
[WARN]2018-02-08 17:27:42.949: ALERT: Could not find parent_id of SF.TaxonNameID = 1234281 (error 2)! Set to animalia_id = 35
[WARN]2018-02-08 18:26:11.172: ALERT: Could not find parent_id of SF.TaxonNameID = 1236452 (error 3)! Set to animalia_id = 24
[ERROR]2018-02-08 18:26:11.357: TaxonName ERROR (count = 1) AFTER synonym test (SF.TaxonNameID = 1236454, parent_id = 24751): Parent The parent rank (subspecies) is not higher than the rank (subspecies) of this taxon
[ERROR]2018-02-08 20:00:50.081: TaxonName ERROR (count = 2) AFTER synonym test (SF.TaxonNameID = 1225991, parent_id = 61293): Parent The parent rank (subspecies) is not higher than the rank (subspecies) of this taxon
[ERROR]2018-02-08 20:09:49.371: TaxonName ERROR (count = 3) AFTER synonym test (SF.TaxonNameID = 1170406, parent_id = 64917): Parent The parent rank (subspecies) is not higher than the rank (subspecies) of this taxon



=end
