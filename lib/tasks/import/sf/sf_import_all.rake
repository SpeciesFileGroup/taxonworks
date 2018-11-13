namespace :tw do
  namespace :project_import do
    namespace :sf_import do

      # @todo: Matt: combinations for citations, cite data_attributes (supplementary_taxon_info), scrutiny authors as roles

      # rake tw:db:restore backup_directory=../db_backup file=../db_backup/0_pristine_tw_init_all/2016-04-26_192513UTC.dump

      desc 'time rake tw:project_import:sf_import:run_all_import_tasks user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
      #  time rake tw:project_import:sf_import:run_all_import_tasks user_id=1 data_directory=/Users/sfg/src/onedb2tw/working/
      task run_all_import_tasks: [

          # 'tw:db:restore backup_directory=../db_backup file=../db_backup/0_pristine_tw_init_all/2016-04-26_192513UTC.dump',
          # rake tw:db:restore_last backup_directory=../db_backup/0_pristine_tw_init_all/

          # 'start:list_skipped_file_ids',
          # 'start:create_users',
          # 'start:create_people',
          # 'start:map_serials',
          # 14m32.537s on 30 Oct 2018
          # 'rake tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/1_after_serials/',

          # 'start:map_ref_links',
          # 'start:list_verbatim_refs',
          # 0m24.701s on 30 Oct 2018
          # 'rake tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/2_after_verbatim_refs/',
          #
          # 'start:create_projects',
          # 'start:create_sf_book_hash',
          # 'start:map_pub_type',
          # 0m27.396s on 30 Oct 2018
          # 'rake tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/3_after_pub_type',
          #
          # 'start:create_sources',
          # 41m36.692s on 31 Oct 2018
          # 'rake tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/4_after_create_sources',
          #
          # 'start:create_misc_ref_info',
          # 'start:create_source_roles',
          # 76m51.040s on 7 Nov 2018
          # 'rake tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/5_after_source_roles',
          #
          #
          # 'taxa:list_excluded_taxa',
          'taxa:create_sf_taxa_misc_info',
          # 'taxa:create_rank_hash',
          # 'taxa:create_animalia_below_root',
          # 'taxa:create_sf_synonym_id_to_new_parent_id_hash',
          # 'taxa:create_otus_for_ill_formed_names_hash',
          # 0m55.165s on 8 Nov 2018
          # 'rake tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/6_after_otus_hash',
          #
          # 'taxa:create_all_sf_taxa_pass1',
          # 298m12.627s on 8 Nov 2018; 347m33.882s on 13 June 2018
          # 'rake tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/7_after_run_all_taxa',
          #
          'taxa:create_type_species',
          'taxa:create_type_genera',
          # 6m40.685s on 13 June 2018
          # 'rake tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/_after_create_types',
          # 
          # 'taxa:create_some_related_taxa',
          # 3m7.015s on 13 June 2018
          # 'rake tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/_after_some_related_taxa',
          #
          # 'taxa:create_status_flag_relationships',
          # 136m0.339s on 13 June
          # 'rake tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/_after_status_flag_rels',
          #
          # ### pre_cites section
          # 'pre_cites:import_nomenclator_strings',
          # 'pre_cites:create_cvts_for_citations',
          # 'pre_cites:create_sf_taxon_name_authors',
          # 'pre_cites:check_original_genus_ids',
          # 15m57.314s on 13 June 2018
          # 'rake tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/_after_orig_genus_ids',
          #
          # ### specimens section
          # 'specimens:create_specimen_unique_id',
          # 'specimens:create_sf_geo_level4_hash',
          # 10m47.481s + some for unique_id on 14 June 2018
          # 'rake tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/_after_geo_level_4',
          #
          # 'specimens:collecting_events',
          # 42m43.927s on 16 June 2018; 47m53.101s on 26 June 2018
          # 'rake tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/_after_coll_events',
          #
          # 'specimens:import_sf_depos',
          # 2m8.814s on 16 June 2018
          #x 'rake tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/_after_sf_depos',
          #
          # 'specimens:create_biocuration_classes',
          #x 'rake tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/_after_biocurations_classes',
          #
          # 'specimens:create_specimen_category_counts',
          #x 'rake tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/_after_specimen_counts',
          #
          # 'specimens:create_sf_source_metadata',
          #x 'rake tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/_after_source_metadata',
          #
          # 'specimens:create_sf_identification_metadata',
          # 7m18.540s on 16 June for 4 tasks: biocuration_classes through identification_metadata
          #x 'rake tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/_after_identification_metadata',
          #
          # 'specimens:get_ident_qualifier_from_nomenclator',
          # 'specimens:create_sf_loc_col_events_metadata',
          # 11m28.712s on June 16 2018; 21m2.541s import_sf_depos through col_events_metadata on 26 June 2018, about 20 min 4 Sept 2018
          # 'rake tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/_after_col_events_metadata',
          #
          # 'specimens:collection_objects',
          # time: 2.75h (178m12.798s on 27 June 2018, 165m44.310s also on 27 June, 165m27.875s also on 27 June), 206m6.374s on 4 Seot 2018
          # 'rake tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/_after_collections_objects'
          #
          # 'taxa:list_excluded_taxa',  # may have to rerun depending on how far back the db was restored
          # 'supplementary:taxon_info',
          # time: 1h (0m57.358s on 29 June 2018, 1m1.335s on 2 July 2018, 1m4.397s on 6 September, 2018)
          # 'rake tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/_after_suppl_info'
          #
          # 'supplementary:scrutiny_related',
          # time: 10m (9m39.816s on 2 July 2018, 9m39.742s on 6 Sept 2018)
          # 'rake tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/_after_scrutinies'    # dump not done 7 Sept 2018
          #
          #
          # 'citations:create_citations',
          # time: close to 10h (592m44.659s on 10 July 2015, 591m42.625s on 6 Sept 2018)
          # 'rake tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/_after_taxon_citations',
          #
          # 'citations:create_otu_cites',
          # time: 1m (1m2.000s on 16 July 2018z0, 0m55.486s on 7 Sept 2018)
          # 'rake tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/_after_otu_cites',

      ] do
        puts 'Ran all tasks!'
      end
    end
  end
end

=begin

General comments:

Create SFTaxonNameIDMiscInfo to take place of SFTaxonNameIDToSFFileID to also include RankID.  Perhaps other column values will be useful at some point in the future.

=end

=begin
Error logs:

=== Summary of warnings and errors for task tw:project_import:sf_import:taxa:create_all_sf_taxa_pass1 ===
[WARN]2018-11-08 12:02:04.251: ALERT: Could not find parent_id of SF.TaxonNameID = 1221949 (error 1)! Set to animalia_id = 25
[WARN]2018-11-08 15:53:44.764: ALERT: Could not find parent_id of SF.TaxonNameID = 1234281 (error 2)! Set to animalia_id = 36
[ERROR]2018-11-08 16:16:29.141: TaxonName ERROR (count = 1) AFTER synonym test (SF.TaxonNameID = 1225991, parent_id = 102765): Parent The parent rank (subspecies) is not higher than the rank (subspecies) of this taxon
[ERROR]2018-11-08 16:26:09.141: TaxonName ERROR (count = 2) AFTER synonym test (SF.TaxonNameID = 1170406, parent_id = 106464): Parent The parent rank (subspecies) is not higher than the rank (subspecies) of this taxon


=end
