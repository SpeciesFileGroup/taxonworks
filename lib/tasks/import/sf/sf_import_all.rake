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
          # 'taxa:create_all_sf_taxa_pass1',
          # 'tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/5_after_run_all_taxa',
          #
          # 'taxa:create_type_species',
          # 'taxa:create_type_genera',
          # 'tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/6_after_create_types',
          #
          # 'taxa:create_some_related_taxa',
          # 'tw:db:dump backup_directory=/Users/mbeckman/src/db_backup/7_after_some_related_taxa',
          #
          'taxa:create_status_flag_relationships',
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

[INFO]2018-02-09 15:23:37.315: Logged task tw:project_import:sf_import:taxa:create_some_related_taxa completed!
[INFO]2018-02-09 15:23:37.315: All tasks completed. Dumping summary for each task...
=== Summary of warnings and errors for task tw:project_import:sf_import:taxa:create_some_related_taxa ===
[ERROR]2018-02-09 15:20:09.419: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1100074 = tw.object_name_id 459 (1): Object taxon name <i>Mirhipipteryx pronotopunctata</i> should not refer to itself
[ERROR]2018-02-09 15:20:09.972: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1100286 = tw.object_name_id 674 (2): Object taxon name <i>Neotridactylus apicialis</i> should not refer to itself
[ERROR]2018-02-09 15:20:11.250: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1100894 = tw.object_name_id 1474 (3): Object taxon name <i>Bolivaritettix sikkimensis</i> should not refer to itself
[ERROR]2018-02-09 15:20:11.756: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1101082 = tw.object_name_id 1676 (4): Object taxon name <i>Xistrella dromadaria</i> should not refer to itself
[ERROR]2018-02-09 15:20:12.270: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1101327 = tw.object_name_id 1880 (5): Object taxon name <i>Systolederus fujianensis</i> should not refer to itself
[ERROR]2018-02-09 15:20:12.338: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1101416 = tw.object_name_id 1967 (6): Object taxon name <i>Cotysoides tibetanius</i> should not refer to itself
[ERROR]2018-02-09 15:20:12.535: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1101613 = tw.object_name_id 2395 (7): Object taxon name <i>Criotettix bannaensis</i> should not refer to itself
[ERROR]2018-02-09 15:20:12.549: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1101624 = tw.object_name_id 2405 (8): Object taxon name <i>Criotettix transpinius</i> should not refer to itself
[ERROR]2018-02-09 15:20:13.029: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1101696 = tw.object_name_id 2490 (9): Object taxon name <i>Amphibotettix abbotti</i> should not refer to itself
[ERROR]2018-02-09 15:20:14.715: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1102653 = tw.object_name_id 3510 (10): Object taxon name <i>Tetrix barbifemura</i> should not refer to itself
[ERROR]2018-02-09 15:20:14.730: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1102657 = tw.object_name_id 3512 (11): Object taxon name <i>Tetrix qilianshanensis</i> should not refer to itself
[ERROR]2018-02-09 15:20:14.746: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1102678 = tw.object_name_id 3532 (12): Object taxon name <i>Tetrix serrifemoroides</i> should not refer to itself
[ERROR]2018-02-09 15:20:15.530: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1102925 = tw.object_name_id 1360 (13): Object taxon name <i>Xerophyllum platycorys platycorys</i> should not refer to itself
[ERROR]2018-02-09 15:20:16.241: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1103279 = tw.object_name_id 4008 (14): Object taxon name <i>Pternoscirta caliginosa</i> should not refer to itself
[ERROR]2018-02-09 15:20:16.822: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1103493 = tw.object_name_id 4334 (15): Object taxon name <i>Oedipoda</i> (<i>caerulescens</i>) <i>caerulescens coerulescens</i> should not refer to itself
[ERROR]2018-02-09 15:20:17.586: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1103772 = tw.object_name_id 4599 (16): Object taxon name <i>Sphingonotus</i> (<i>Sphingonotus</i>) <i>pilosus</i> should not refer to itself
[ERROR]2018-02-09 15:20:19.668: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1105351 = tw.object_name_id 6159 (17): Object taxon name <i>Aulacobothrus svenhedini</i> should not refer to itself
[ERROR]2018-02-09 15:20:20.172: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1105619 = tw.object_name_id 6431 (18): Object taxon name <i>Eremippus mirami</i> should not refer to itself
[ERROR]2018-02-09 15:20:20.362: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1105697 = tw.object_name_id 6508 (19): Object taxon name <i>Mizonocara kusnetzovae</i> should not refer to itself
[ERROR]2018-02-09 15:20:22.809: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1107494 = tw.object_name_id 16569 (20): Object taxon name <i>Pezotettix giornae</i> should not refer to itself
[ERROR]2018-02-09 15:20:24.164: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1108540 (1)
[ERROR]2018-02-09 15:20:25.501: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1109758 = tw.object_name_id 10492 (21): Object taxon name <i>Barytettix humphreysii humphreysii</i> should not refer to itself
[ERROR]2018-02-09 15:20:27.122: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1111279 = tw.object_name_id 11765 (22): Object taxon name <i>Prumna jingpohu</i> should not refer to itself
[ERROR]2018-02-09 15:20:27.680: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1111668 = tw.object_name_id 12650 (23): Object taxon name <i>Aeropedelloides changtunensis</i> should not refer to itself
[ERROR]2018-02-09 15:20:28.274: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1112107 = tw.object_name_id 13077 (24): Object taxon name <i>Parga rhodioptera</i> should not refer to itself
[ERROR]2018-02-09 15:20:29.057: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1112671 = tw.object_name_id 13646 (25): Object taxon name <i>Ornithacris cyanea imperialis</i> should not refer to itself
[ERROR]2018-02-09 15:20:30.569: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1113696 = tw.object_name_id 14701 (26): Object taxon name <i>Eyprepocnemis</i> should not refer to itself
[ERROR]2018-02-09 15:20:32.804: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1115053 = tw.object_name_id 16083 (27): Object taxon name <i>Orthoscapheus coriaceus</i> should not refer to itself
[ERROR]2018-02-09 15:20:33.022: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1115128 = tw.object_name_id 16160 (28): Object taxon name <i>Liebermannacris dorsualis</i> should not refer to itself
[ERROR]2018-02-09 15:20:33.522: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1115524 = tw.object_name_id 16605 (29): Object taxon name <i>Pyrgacris relictus</i> should not refer to itself
[ERROR]2018-02-09 15:20:33.762: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1115664 = tw.object_name_id 16733 (30): Object taxon name <i>Chromousambilla burtti</i> should not refer to itself
[ERROR]2018-02-09 15:20:39.658: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1119510 = tw.object_name_id 20706 (31): Object taxon name <i>Masyntes gundlachii</i> should not refer to itself
[ERROR]2018-02-09 15:20:40.643: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1120356 = tw.object_name_id 21635 (32): Object taxon name <i>Atractomorpha</i> should not refer to itself
[ERROR]2018-02-09 15:20:42.772: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1121371 = tw.object_name_id 22636 (33): Object taxon name <i>Physophorina livingstonii</i> should not refer to itself
[ERROR]2018-02-09 15:20:43.707: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1121930 = tw.object_name_id 29140 (34): Object taxon name <i>Allonemobius sparsalsus</i> should not refer to itself
[ERROR]2018-02-09 15:20:43.876: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1122120 = tw.object_name_id 22880 (35): Object taxon name <i>Landreva erromanga</i> should not refer to itself
[ERROR]2018-02-09 15:20:44.013: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1122258 = tw.object_name_id 23100 (36): Object taxon name <i>Cophogryllus delalandi</i> should not refer to itself
[ERROR]2018-02-09 15:20:44.166: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1122452 (2)
[ERROR]2018-02-09 15:20:48.143: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1125732 = tw.object_name_id 27733 (37): Object taxon name <i>Mikluchomaklaia</i> (<i>Stridulacla</i>) <i>biaru</i> should not refer to itself
[ERROR]2018-02-09 15:20:52.651: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1127689 = tw.object_name_id 26851 (38): Object taxon name <i>Cardiodactylus</i> (<i>novaeguineae</i>) <i>boharti</i> should not refer to itself
[ERROR]2018-02-09 15:20:53.226: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1128149 (3)
[ERROR]2018-02-09 15:20:54.267: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1128799 (4)
[ERROR]2018-02-09 15:20:55.080: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1129692 = tw.object_name_id 31231 (39): Object taxon name <i>Eutachycines gialaiensis</i> should not refer to itself
[ERROR]2018-02-09 15:20:56.554: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1130484 = tw.object_name_id 32129 (40): Object taxon name <i>Troglophilus</i> (<i>Troglophilus</i>) <i>andreinii andreinii</i> should not refer to itself
[ERROR]2018-02-09 15:20:57.988: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1131437 = tw.object_name_id 33579 (41): Object taxon name <i>Gryllacris</i> (<i>fuscifrons</i>) <i>jacobsonii</i> should not refer to itself
[ERROR]2018-02-09 15:20:59.208: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1131960 = tw.object_name_id 34146 (42): Object taxon name <i>Faku</i> should not refer to itself
[ERROR]2018-02-09 15:20:59.424: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1132210 = tw.object_name_id 34396 (43): Object taxon name &#8224; <i>Zeuneroptera scotica</i> should not refer to itself
[ERROR]2018-02-09 15:21:00.057: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1132517 = tw.object_name_id 34713 (44): Object taxon name <i>Neocallicrania selligera seoanei</i> should not refer to itself
[ERROR]2018-02-09 15:21:00.388: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1132641 (5)
[ERROR]2018-02-09 15:21:00.684: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1132892 = tw.object_name_id 35540 (45): Object taxon name <i>Agraecia agraecioides</i> should not refer to itself
[ERROR]2018-02-09 15:21:01.180: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1133443 = tw.object_name_id 35782 (46): Object taxon name <i>Conocephalus</i> (<i>Anisoptera</i>) <i>melaenus</i> should not refer to itself
[ERROR]2018-02-09 15:21:01.503: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1133657 = tw.object_name_id 35993 (47): Object taxon name <i>Orchelimum</i> (<i>Orchelimum</i>) <i>silvaticum</i> should not refer to itself
[ERROR]2018-02-09 15:21:03.309: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1134938 = tw.object_name_id 37325 (48): Object taxon name <i>Meconema varia</i> should not refer to itself
[ERROR]2018-02-09 15:21:06.527: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1136782 = tw.object_name_id 42551 (49): Object taxon name <i>Plagiopleura nigromarginata</i> should not refer to itself
[ERROR]2018-02-09 15:21:08.028: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1137189 = tw.object_name_id 39041 (50): Object taxon name <i>Acrometopa festae</i> should not refer to itself
[ERROR]2018-02-09 15:21:10.142: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1138525 = tw.object_name_id 40103 (51): Object taxon name <i>Elimaea</i> (<i>Poaefoliana</i>) (<i>poaefolia</i>) <i>jacobsonii</i> should not refer to itself
[ERROR]2018-02-09 15:21:11.664: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1139423 = tw.object_name_id 41346 (52): Object taxon name <i>Steirodon</i> (<i>Posidippum</i> [sic]) should not refer to itself
[ERROR]2018-02-09 15:21:11.935: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1139540 = tw.object_name_id 44396 (53): Object taxon name <i>Phasmodes ranatriformis</i> should not refer to itself
[ERROR]2018-02-09 15:21:16.080: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1141525 (6)
[ERROR]2018-02-09 15:21:16.808: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1142246 = tw.object_name_id 45152 (54): Object taxon name <i>Idiostatus hermannii</i> should not refer to itself
[ERROR]2018-02-09 15:21:16.944: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1142512 = tw.object_name_id 45428 (55): Object taxon name <i>Metrioptera saussuriana</i> should not refer to itself
[ERROR]2018-02-09 15:21:17.263: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1142854 = tw.object_name_id 45774 (56): Object taxon name <i>Gampsocleis buergeri</i> should not refer to itself
[ERROR]2018-02-09 15:21:17.358: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 2, SF.OlderNameID 1142938 = tw.object_name_id 45856 (57): Object taxon name <i>Decticus verrucivorus monspeliensis</i> should not refer to itself
[ERROR]2018-02-09 15:21:17.939: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1143406 (7)
[ERROR]2018-02-09 15:21:17.939: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1143419 (8)
[ERROR]2018-02-09 15:21:17.939: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1143438 (9)
[ERROR]2018-02-09 15:21:20.610: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 11, SF.OlderNameID 1155116 = tw.object_name_id 49516 (58): Object taxon name <i>Paraleuctra gracilis</i> should not refer to itself
[ERROR]2018-02-09 15:21:23.029: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1157740 (10)
[ERROR]2018-02-09 15:21:27.602: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1159491 (11)
[ERROR]2018-02-09 15:21:28.513: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 13, SF.OlderNameID 1159573 = tw.object_name_id 53664 (59): Object taxon name &#8224; <i>Leptocallites xilutianensis</i> should not refer to itself
[ERROR]2018-02-09 15:21:29.175: TaxonNameRelationship SUPPRESSED younger name SF.TaxonNameID = 1204156 (12)
[ERROR]2018-02-09 15:21:37.329: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1161214 (13)
[ERROR]2018-02-09 15:21:37.507: TaxonNameRelationship SUPPRESSED younger name SF.TaxonNameID = 1161217 (14)
[ERROR]2018-02-09 15:21:38.865: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1161399 (15)
[ERROR]2018-02-09 15:21:38.865: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1161401 (16)
[ERROR]2018-02-09 15:21:52.091: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 13, SF.OlderNameID 1163062 = tw.object_name_id 57189 (60): Object taxon name <i>Lachnus roboris börneri</i> should not refer to itself
[ERROR]2018-02-09 15:21:54.335: TaxonNameRelationship SUPPRESSED younger name SF.TaxonNameID = 1221657 (17)
[ERROR]2018-02-09 15:22:12.262: TaxonNameRelationship SUPPRESSED younger name SF.TaxonNameID = 1221814 (18)
[ERROR]2018-02-09 15:22:13.197: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1166156 (19)
[ERROR]2018-02-09 15:22:23.191: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1167757 (20)
[ERROR]2018-02-09 15:22:34.313: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 13, SF.OlderNameID 1169382 = tw.object_name_id 63854 (61): Object taxon name <i>Nasonovia</i> (<i>Nasonovia</i>) <i>kaltenbachi</i> should not refer to itself
[ERROR]2018-02-09 15:22:45.733: TaxonNameRelationship SUPPRESSED younger name SF.TaxonNameID = 1225760 (21)
[ERROR]2018-02-09 15:22:55.783: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1179483 (22)
[ERROR]2018-02-09 15:23:00.307: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1187513 (23)
[ERROR]2018-02-09 15:23:03.364: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1188982 (24)
[ERROR]2018-02-09 15:23:08.456: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 6, SF.OlderNameID 1190407 = tw.object_name_id 85060 (62): Object taxon name <i>Acanthocephala thomasi</i> should not refer to itself
[ERROR]2018-02-09 15:23:10.578: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 9, SF.OlderNameID 1191724 = tw.object_name_id 86906 (63): Object taxon name <i>Psyllipsocus ramburii</i> should not refer to itself
[ERROR]2018-02-09 15:23:11.223: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 9, SF.OlderNameID 1192184 = tw.object_name_id 86765 (64): Object taxon name <i>Troctes</i> should not refer to itself
[ERROR]2018-02-09 15:23:11.415: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 9, SF.OlderNameID 1192707 = tw.object_name_id 87495 (65): Object taxon name <i>Caecilius</i> should not refer to itself
[ERROR]2018-02-09 15:23:11.614: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 9, SF.OlderNameID 1193043 = tw.object_name_id 87780 (66): Object taxon name <i>Coryphaca misionarius</i> should not refer to itself
[ERROR]2018-02-09 15:23:13.181: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 9, SF.OlderNameID 1193753 = tw.object_name_id 88490 (67): Object taxon name <i>Stenopsocus immaulatus</i> should not refer to itself
[ERROR]2018-02-09 15:23:15.090: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 9, SF.OlderNameID 1197378 = tw.object_name_id 91099 (68): Object taxon name <i>Metylophorus yanezi</i> should not refer to itself
[ERROR]2018-02-09 15:23:15.774: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 9, SF.OlderNameID 1198059 = tw.object_name_id 91670 (69): Object taxon name <i>Trichadenotecnum minsexmaculatum</i> should not refer to itself
[ERROR]2018-02-09 15:23:17.718: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1200032 (25)
[ERROR]2018-02-09 15:23:17.719: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1200034 (26)
[ERROR]2018-02-09 15:23:17.837: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1200142 (27)
[ERROR]2018-02-09 15:23:18.053: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1200168 (28)
[ERROR]2018-02-09 15:23:20.732: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1201068 (29)
[ERROR]2018-02-09 15:23:24.948: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1202224 (30)
[ERROR]2018-02-09 15:23:24.948: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1202226 (31)
[ERROR]2018-02-09 15:23:26.520: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1202930 (32)
[ERROR]2018-02-09 15:23:26.586: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1202948 (33)
[ERROR]2018-02-09 15:23:28.373: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1203986 (34)
[ERROR]2018-02-09 15:23:28.927: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1216649 (35)
[ERROR]2018-02-09 15:23:31.312: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1221326 (36)
[ERROR]2018-02-09 15:23:31.313: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1221327 (37)
[ERROR]2018-02-09 15:23:31.485: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1221811 (38)
[ERROR]2018-02-09 15:23:31.486: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1221821 (39)
[ERROR]2018-02-09 15:23:31.878: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1222168 (40)
[ERROR]2018-02-09 15:23:32.163: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1222312 (41)
[ERROR]2018-02-09 15:23:32.418: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1222911 (42)
[ERROR]2018-02-09 15:23:32.419: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1222911 (43)
[ERROR]2018-02-09 15:23:32.896: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1223080 (44)
[ERROR]2018-02-09 15:23:35.973: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1232967 (45)
[ERROR]2018-02-09 15:23:36.035: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1234009 (46)
[ERROR]2018-02-09 15:23:36.035: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1234010 (47)
[ERROR]2018-02-09 15:23:36.036: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1234011 (48)
[ERROR]2018-02-09 15:23:36.036: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1234012 (49)


=end
