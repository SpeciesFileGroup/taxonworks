namespace :tw do
  namespace :project_import do
    namespace :sf_import do

      # rake tw:db:restore backup_directory=../db_backup file=../db_backup/0_pristine_tw_init_all/2016-04-26_192513UTC.dump

      desc 'time rake tw:project_import:sf_import:run_all_import_tasks user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
      task :run_all_import_tasks => [
          # 'start:create_users',
          # 'start:create_people',
          # 'start:map_serials',
          # 'start:map_ref_links',
          # 'start:list_verbatim_refs',
          # 'start:create_projects',
          # 'start:create_sf_book_hash',
          # 'start:map_pub_type',
          #  'start:create_sources',
          #  'start:create_source_editor_array',
          #  'start:create_source_roles',

          #  'taxa:create_rank_hash',
          #  'taxa:create_animalia_below_root',
          #  'taxa:create_sf_synonym_id_to_new_parent_id_hash',
          #  'taxa:create_otus_for_ill_formed_names_hash',
          #  'taxa:create_all_sf_taxa_pass1',
          #  'taxa:create_type_species',
          #  'taxa:create_type_genera',
          #  'taxa:create_some_related_taxa',
           'taxa:create_status_flag_relationships',

          #  'cites:import_nomenclator_strings',
          #    'cites:create_cvts_for_citations',
          #    'cites:create_citations'
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
[ERROR]2017-03-15 16:09:06.354: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1100286 = tw.object_name_id 840 (1): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:07.301: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1100894 = tw.object_name_id 1626 (2): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:07.559: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1101082 = tw.object_name_id 1817 (3): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:07.747: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1101327 = tw.object_name_id 2034 (4): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:07.829: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1101416 = tw.object_name_id 2116 (5): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:07.989: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1101613 = tw.object_name_id 2443 (6): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:08.000: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1101624 = tw.object_name_id 2453 (7): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:08.257: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1101696 = tw.object_name_id 2532 (8): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:09.326: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1102653 = tw.object_name_id 3518 (9): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:10.637: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1103279 = tw.object_name_id 3987 (10): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:11.012: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1103493 = tw.object_name_id 4286 (11): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:11.482: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1103772 = tw.object_name_id 4549 (12): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:13.114: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1105619 = tw.object_name_id 6399 (13): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:13.125: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1105697 = tw.object_name_id 6476 (14): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:15.587: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1108540 (1)
[ERROR]2017-03-15 16:09:16.552: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1109758 = tw.object_name_id 10438 (15): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:18.345: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1112107 = tw.object_name_id 13005 (16): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:18.867: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1112671 = tw.object_name_id 13571 (17): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:19.920: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1113696 = tw.object_name_id 14624 (18): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:21.349: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1115053 = tw.object_name_id 15995 (19): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:21.482: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1115128 = tw.object_name_id 16072 (20): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:21.805: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1115524 = tw.object_name_id 16508 (21): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:22.014: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1115664 = tw.object_name_id 16636 (22): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:25.866: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1119510 = tw.object_name_id 20524 (23): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:26.600: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1120356 = tw.object_name_id 21449 (24): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:28.008: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1121371 = tw.object_name_id 22444 (25): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:28.984: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1122258 = tw.object_name_id 22839 (26): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:29.084: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1122452 (2)
[ERROR]2017-03-15 16:09:31.973: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1125732 = tw.object_name_id 27354 (27): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:35.197: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1127689 = tw.object_name_id 26363 (28): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:35.626: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1128149 (3)
[ERROR]2017-03-15 16:09:36.231: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1128799 (4)
[ERROR]2017-03-15 16:09:36.688: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1129692 = tw.object_name_id 30761 (29): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:37.622: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1130484 = tw.object_name_id 31627 (30): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:38.640: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1131437 = tw.object_name_id 33073 (31): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:39.456: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1131960 = tw.object_name_id 33632 (32): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:39.581: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1132210 = tw.object_name_id 33884 (33): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:39.975: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1132517 = tw.object_name_id 34198 (34): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:40.196: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1132641 (5)
[ERROR]2017-03-15 16:09:40.335: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1132892 = tw.object_name_id 35001 (35): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:40.682: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1133443 = tw.object_name_id 35240 (36): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:42.146: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1134938 = tw.object_name_id 36759 (37): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:44.362: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1136782 = tw.object_name_id 41815 (38): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:45.385: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1137189 = tw.object_name_id 38427 (39): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:46.801: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1138525 = tw.object_name_id 39492 (40): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:47.840: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1139423 = tw.object_name_id 40686 (41): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:50.763: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1141525 (6)
[ERROR]2017-03-15 16:09:51.174: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1142246 = tw.object_name_id 44362 (42): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:51.262: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1142512 = tw.object_name_id 44636 (43): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:51.480: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1142854 = tw.object_name_id 44983 (44): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:51.576: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 42, SF.OlderNameID 1142938 = tw.object_name_id 45064 (45): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:51.984: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1143406 (7)
[ERROR]2017-03-15 16:09:51.984: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1143419 (8)
[ERROR]2017-03-15 16:09:51.985: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1143438 (9)
[ERROR]2017-03-15 16:09:55.912: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 60, SF.OlderNameID 1147136 = tw.object_name_id 48874 (46): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:09:58.925: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1148368 (10)
[ERROR]2017-03-15 16:10:07.011: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 52, SF.OlderNameID 1155116 = tw.object_name_id 56735 (47): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:10:08.518: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1157740 (11)
[ERROR]2017-03-15 16:10:11.445: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1159491 (12)
[ERROR]2017-03-15 16:10:12.384: TaxonNameRelationship SUPPRESSED younger name SF.TaxonNameID = 1204156 (13)
[ERROR]2017-03-15 16:10:17.829: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1161214 (14)
[ERROR]2017-03-15 16:10:17.936: TaxonNameRelationship SUPPRESSED younger name SF.TaxonNameID = 1161217 (15)
[ERROR]2017-03-15 16:10:18.810: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1161399 (16)
[ERROR]2017-03-15 16:10:18.810: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1161401 (17)
[ERROR]2017-03-15 16:10:27.798: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 54, SF.OlderNameID 1163062 = tw.object_name_id 64371 (48): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:10:29.292: TaxonNameRelationship SUPPRESSED younger name SF.TaxonNameID = 1221657 (18)
[ERROR]2017-03-15 16:10:41.463: TaxonNameRelationship SUPPRESSED younger name SF.TaxonNameID = 1221814 (19)
[ERROR]2017-03-15 16:10:42.126: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1166156 (20)
[ERROR]2017-03-15 16:10:48.553: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1167757 (21)
[ERROR]2017-03-15 16:10:56.179: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 54, SF.OlderNameID 1169382 = tw.object_name_id 70868 (49): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:11:04.085: TaxonNameRelationship SUPPRESSED younger name SF.TaxonNameID = 1225760 (22)
[ERROR]2017-03-15 16:11:11.283: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1179483 (23)
[ERROR]2017-03-15 16:11:14.496: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1187513 (24)
[ERROR]2017-03-15 16:11:16.679: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1188982 (25)
[ERROR]2017-03-15 16:11:21.863: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 49, SF.OlderNameID 1191724 = tw.object_name_id 93875 (50): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:11:22.296: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 49, SF.OlderNameID 1192184 = tw.object_name_id 93734 (51): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:11:22.457: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 49, SF.OlderNameID 1192707 = tw.object_name_id 94464 (52): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:11:22.549: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 49, SF.OlderNameID 1193043 = tw.object_name_id 94749 (53): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:11:23.626: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 49, SF.OlderNameID 1193753 = tw.object_name_id 95458 (54): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:11:24.947: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 49, SF.OlderNameID 1197378 = tw.object_name_id 98067 (55): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:11:25.424: TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id 49, SF.OlderNameID 1198059 = tw.object_name_id 98639 (56): Object taxon name Taxon should not refer to itself
[ERROR]2017-03-15 16:11:26.382: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1200032 (26)
[ERROR]2017-03-15 16:11:26.383: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1200034 (27)
[ERROR]2017-03-15 16:11:26.478: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1200142 (28)
[ERROR]2017-03-15 16:11:26.583: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1200168 (29)
[ERROR]2017-03-15 16:11:27.526: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1201068 (30)
[ERROR]2017-03-15 16:11:29.476: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1202224 (31)
[ERROR]2017-03-15 16:11:29.477: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1202226 (32)
[ERROR]2017-03-15 16:11:30.350: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1202930 (33)
[ERROR]2017-03-15 16:11:30.350: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1202948 (34)
[ERROR]2017-03-15 16:11:31.299: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1203986 (35)
[ERROR]2017-03-15 16:11:31.709: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1216649 (36)
[ERROR]2017-03-15 16:11:33.697: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1221326 (37)
[ERROR]2017-03-15 16:11:33.697: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1221327 (38)
[ERROR]2017-03-15 16:11:33.829: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1221811 (39)
[ERROR]2017-03-15 16:11:33.830: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1221821 (40)
[ERROR]2017-03-15 16:11:34.118: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1222168 (41)
[ERROR]2017-03-15 16:11:34.335: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1222312 (42)
[ERROR]2017-03-15 16:11:34.513: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1222911 (43)
[ERROR]2017-03-15 16:11:34.513: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1222911 (44)
[ERROR]2017-03-15 16:11:34.867: TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = 1223080 (45)

:create_status_flag_relationships
  - 234 failed attempts to create TaxonNameRelationships, mostly due to rank issues
  - Created note for each failure detailing SF status flag value, attempted relationship, error message

taxa:create_all_sf_taxa_pass1
[INFO]2017-03-15 15:43:39.366: Logged task tw:project_import:sf_import:taxa:create_all_sf_taxa_pass1 completed!
[INFO]2017-03-15 15:43:39.367: All tasks completed. Dumping summary for each task...
=== Summary of warnings and errors for task tw:project_import:sf_import:taxa:create_all_sf_taxa_pass1 ===
[ERROR]2017-03-15 13:11:40.264: TaxonName ERROR (1) AFTER synonym test (SF.TaxonNameID = 1225991, parent_id = 68332): Parent The parent rank (subspecies) is not higher than subspecies
[ERROR]2017-03-15 13:20:22.621: TaxonName ERROR (2) AFTER synonym test (SF.TaxonNameID = 1170406, parent_id = 71920): Parent The parent rank (subspecies) is not higher than subspecies



=end
