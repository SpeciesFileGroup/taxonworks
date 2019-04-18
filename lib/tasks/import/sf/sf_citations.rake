# rake tw:db:restore backup_directory=/Users/proceps/src/sf/import/onedb2tw/snapshots/15_after_scrutinies/ file=localhost_2018-09-26_212447UTC.dump

namespace :tw do
  namespace :project_import do
    namespace :sf_import do
      require 'fileutils'
      require 'logged_task'
      namespace :citations do

        desc 'time rake tw:project_import:sf_import:citations:create_otu_cites user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define create_otu_cites: [:data_directory, :environment, :user_id] do |logger|

         logger.info 'Creating citations for OTUs...'

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping
          get_tw_project_id = import.get('SFFileIDToTWProjectID')
          # get_tw_taxon_name_id = import.get('SFTaxonNameIDToTWTaxonNameID')
          get_tw_otu_id = import.get('SFTaxonNameIDToTWOtuID') # Note this is an OTU associated with a SF.TaxonNameID (probably a bad taxon name)
          # get_taxon_name_otu_id = import.get('TWTaxonNameIDToOtuID') # Note this is the OTU offically associated with a real TW.taxon_name_id
          get_tw_source_id = import.get('SFRefIDToTWSourceID')
          # get_nomenclator_string = import.get('SFNomenclatorIDToSFNomenclatorString')
          get_nomenclator_metadata = import.get('SFNomenclatorIDToSFNomenclatorMetadata')
          get_cvt_id = import.get('CvtProjUriID')
          # get_containing_source_id = import.get('TWSourceIDToContainingSourceID') # use to determine if taxon_name_author must be created (orig desc only)
          # get_sf_taxon_name_authors = import.get('SFRefIDToTaxonNameAuthors') # contains ordered array of SF.PersonIDs

          path = @args[:data_directory] + 'tblCites.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

          # tblCites columns: TaxonNameID, SeqNum, RefID, CitePages, Note, NomenclatorID, NewNameStatusID, TypeInfoID, ConceptChangeID, CurrentConcept, InfoFlags, InfoFlagStatus, PolynomialStatus, [housekeeping]
          #   Handle: TaxonNameID, RefID, CitePages, Note, NomenclatorID (verbatim), NewNameStatus(ID), TypeInfo(ID), InfoFlags, InfoFlagStatus, [housekeeping]
          #   Do not handle: Seqnum, ConceptChangeID, CurrentConcept, PolynomialStatus


          count_found = 0
          error_counter = 0
          # no_taxon_counter = 0
          cite_found_counter = 0
          # otu_not_found_counter = 0
          orig_desc_source_id = 0 # make sure only first cite to original description is handled as such (when more than one cite to same source)
          # otu_only_counter = 0

          base_uri = 'http://speciesfile.org/legacy/'

          file.each_with_index do |row, i|
            sf_taxon_name_id = row['TaxonNameID']
            next unless get_tw_otu_id.has_key?(sf_taxon_name_id)

            sf_ref_id = row['RefID']
            source_id = get_tw_source_id[sf_ref_id].to_i
            next if source_id == 0

            otu = Otu.find(get_tw_otu_id[sf_taxon_name_id]) # need otu object for project_id and
            project_id = otu.project_id.to_s

#            logger.info "Working with TW.project_id: #{project_id}, SF.TaxonNameID #{sf_taxon_name_id} = TW.otu_id #{otu.id},
#        SF.RefID #{sf_ref_id} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']} (count #{count_found += 1}) \n"

            #cite_pages = row['CitePages']

            new_name_uri = (base_uri + 'new_name_status/' + row['NewNameStatusID']) unless row['NewNameStatusID'] == '0'
            type_info_uri = (base_uri + 'type_info/' + row['TypeInfoID']) unless row['TypeInfoID'] == '0'
            info_flag_status_uri = (base_uri + 'info_flag_status/' + row['InfoFlagStatus']) unless row['InfoFlagStatus'] == '0'

            new_name_cvt_id = get_cvt_id[project_id][new_name_uri]
            type_info_cvt_id = get_cvt_id[project_id][type_info_uri]
            info_flag_status_cvt_id = get_cvt_id[project_id][info_flag_status_uri]

            info_flags = row['InfoFlags'].to_i
            citation_topics_attributes = []

            if info_flags > 0
              base_cite_info_flags_uri = (base_uri + 'cite_info_flags/') # + bit_position below
              cite_info_flags_array = Utilities::Numbers.get_bits(info_flags)

              citation_topics_attributes = cite_info_flags_array.collect {|bit_position|
                {topic_id: get_cvt_id[project_id][base_cite_info_flags_uri + bit_position.to_s],
                 project_id: project_id,
                 created_at: row['CreatedOn'],
                 updated_at: row['LastUpdate'],
                 created_by_id: get_tw_user_id[row['CreatedBy']],
                 updated_by_id: get_tw_user_id[row['ModifiedBy']]
                }
              }
            end

            # citation_topics_attributes ||= [] # or or equals

            metadata = {
                ## Note: Add as attribute before save citation
                notes_attributes: [{text: row['Note'], # (row['Note'].blank? ? nil :   rejected automatically by notable
                                    project_id: project_id,
                                    created_at: row['CreatedOn'],
                                    updated_at: row['LastUpdate'],
                                    created_by_id: get_tw_user_id[row['CreatedBy']],
                                    updated_by_id: get_tw_user_id[row['ModifiedBy']]}],

                ## NewNameStatus: As tags to citations, create 16 keywords for each project, set up in case statement; test for NewNameStatusID > 0
                ## TypeInfo: As tags to citations, create n keywords for each project, set up in case statement (2364 cases!)
                # tags_attributes: [
                #     #  {keyword_id: (row['NewNameStatus'].to_i > 0 ?
                # ControlledVocabularyTerm.where('uri LIKE ? and project_id = ?', "%/new_name_status/#{row['NewNameStatusID']}", project_id).limit(1).pluck(:id).first : nil), project_id: project_id},
                #     #  {keyword_id: (row['TypeInfoID'].to_i > 0 ? ControlledVocabularyTerm.where('uri LIKE ? and project_id = ?', "%/type_info/#{row['TypeInfoID']}", project_id).limit(1).pluck(:id).first : nil), project_id: project_id}
                #     {keyword_id: (new_name_uri ? new_name_cvt_id : nil), project_id: project_id},
                #     {keyword_id: (type_info_uri ? Keyword.where('uri = ? AND project_id = ?', type_info_uri, project_id).limit(1).pluck(:id).first : nil), project_id: project_id}
                #
                # ],

                tags_attributes: [{keyword_id: new_name_cvt_id, project_id: project_id}, {keyword_id: type_info_cvt_id, project_id: project_id}],

                ## InfoFlagStatus: Add confidence, 1 = partial data or needs review, 2 = complete data
                confidences_attributes: [{confidence_level_id: info_flag_status_cvt_id, project_id: project_id}],
                citation_topics_attributes: citation_topics_attributes
            }

            # byebug

            citation = Citation.new(
                metadata.merge(
                    source_id: source_id,
                    pages: row['CitePages'],
                    # is_original: (row['SeqNum'] == '1' ? true : false),
                    citation_object: otu,

                    # housekeeping for citation
                    project_id: project_id,
                    created_at: row['CreatedOn'],
                    updated_at: row['LastUpdate'],
                    created_by_id: get_tw_user_id[row['CreatedBy']],
                    updated_by_id: get_tw_user_id[row['ModifiedBy']]
                )
            )

            begin
              citation.save!
            rescue ActiveRecord::RecordInvalid # citation not valid

              # yes I know this is ugly but it works
              if citation.errors.messages[:source_id].nil?
                logger.error "Citation ERROR [TW.project_id: #{project_id}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{taxon_name_id},
SF.RefID #{sf_ref_id} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']}] (#{error_counter += 1}): " + citation.errors.full_messages.join(';')
                next
              else # make pages unique and save again
                if citation.errors.messages[:source_id].include?('has already been taken') # citation.errors.messages[:source_id][0] == 'has already been taken'
                  citation.pages = "#{row['CitePages']} [dupl #{row['SeqNum']}"
                  begin
                    citation.save!
                  rescue ActiveRecord::RecordInvalid
                    logger.error "Citation ERROR [TW.project_id: #{project_id}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{taxon_name_id}, SF.RefID #{sf_ref_id} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']}] (#{error_counter += 1}): " + citation.errors.full_messages.join(';')
                    next
                  end
                else # citation error was not already been taken (other validation failure)
                  logger.error "Citation ERROR [TW.project_id: #{project_id}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{taxon_name_id}, SF.RefID #{sf_ref_id} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']}] (#{error_counter += 1}): " + citation.errors.full_messages.join(';')
                  next
                end
              end
            end

            # kluge that worked but even uglier
            # old_citation = Citation.where(source_id: source_id, citation_object: otu).first # instantiate so nomenclator string can be appended
            # logger.info "Citation (= #{old_citation.id}) to this OTU (= #{otu.id}, SF.TaxonNameID #{sf_taxon_name_id}) from this source (= #{source_id}, SF.RefID #{sf_ref_id}) with these pages (= #{row['CitePages']}) already exists (cite_found_counter = #{cite_found_counter += 1})"
            # old_citation.notes << Note.new(text: "Duplicate citation source to same OTU; nomenclator string = '#{get_nomenclator_string[row['NomenclatorID']]}'", project_id: project_id)
            # # note_text = row['Note'].gsub('|', ':')
            # old_citation.notes << Note.new(text: "Note for duplicate citation = '#{row['Note']}'", project_id: project_id) unless row['Note'].blank?


            ### After citation updated or created

            ## Nomenclator: DataAttribute of citation, NomenclatorID > 0
            if row['NomenclatorID'] != '0' # OR could value: be evaluated below based on NomenclatorID?

              da = DataAttribute.create!(type: 'ImportAttribute',
                                         attribute_subject: citation.citation_object, # replaces next two lines
                                         # attribute_subject_id: citation.id,
                                         # attribute_subject_type: 'Citation',
                                         import_predicate: 'Nomenclator',
                                         value: get_nomenclator_metadata[row['NomenclatorID']]['nomenclator_string'],
                                         project_id: project_id,
                                         created_at: row['CreatedOn'],
                                         updated_at: row['LastUpdate'],
                                         created_by_id: get_tw_user_id[row['CreatedBy']],
                                         updated_by_id: get_tw_user_id[row['ModifiedBy']]
              )
              da.citation.create!(source_id: citation.source_id, project_id: project_id)

            end
          end
        end


        def nomenclator_is_original_combination?(protonym, nomenclator_string)
          protonym.cached_original_combination == "<i>#{nomenclator_string}</i>"
        end

        def nomenclator_is_current_name?(protonym, nomenclator_string)
          protonym.cached == nomenclator_string
        end

        def m_original_combination(kn)
          return false, nil if !kn[:is_original_combination]

          id = kn[:protonym].id
          kn[:cr].disambiguate_combination(genus: id, subgenus: id, species: id, subspecies: id, variety: id, form: id)
          kn[:protonym].build_original_combination_from_biodiversity(kn[:cr], kn[:housekeeping_params])
          kn[:protonym].save!
          return true, kn[:protonym]
        end

        def m_single_match(kn) # test for single match
          potential_matches = TaxonName.where(cached: kn[:nomenclator_string], project_id: kn[:project_id])
          if potential_matches.count == 1
            puts 'm_single_match'
            return true, potential_matches.first
          end
          return false, nil
        end

        def m_unambiguous(kn) # test combination is unambiguous and has genus
          if kn[:cr].is_unambiguous?
            if kn[:cr].genus
              puts 'm_unambiguous'
              return true, kn[:cr].combination
            end
          end
          return false, nil
        end

        def m_current_species_homonym(kn) # test known genus and current species homonym
          if kn[:protonym].rank == "species"
            a = kn[:cr].disambiguate_combination(species: kn[:protonym].id)
            if a.get_full_name == kn[:nomenclator_string]
              puts 'm_current_species_homonym'
              return true, a
            end
          end
          return false, nil
        end


        # Returns a symbol/name of the decision to
        # be taken for the row in question
        def decide(knowns)


        end

        # something that can be called in decide
        def decide_method_a

        end




       ###################################################################################################### Nomenclator 1st pass

        # Prior to running next task:
        #   Which dump file to restore
        desc 'time rake tw:project_import:sf_import:citations:create_citations user_id=1 data_directory=/Users/proceps/src/sf/import/onedb2tw/working/'
        #desc 'time rake tw:project_import:sf_import:citations:create_citations user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define create_citations: [:data_directory, :environment, :user_id] do |logger|


          logger.info 'Creating citations...'

          Current.project_id = 2
          Current.user_id = 1
          pwd = rand(36**10).to_s(36)
          @proceps = User.where(email: 'arboridia@gmail.com').first
          @proceps = User.create(email: 'arboridia@gmail.com', password: pwd, password_confirmation: pwd, name: 'proceps', is_administrator: true, self_created: true, is_flagged_for_password_reset: true) if @proceps.nil?
          pm = ProjectMember.create(user: @proceps, project_id: Current.project_id, is_project_administrator: true)
          Current.user_id = @proceps.id
          import = Import.find_or_create_by(name: 'SpeciesFileData')
          skipped_file_ids = import.get('SkippedFileIDs')
          excluded_taxa = import.get('ExcludedTaxa')
          get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping
          get_tw_project_id = import.get('SFFileIDToTWProjectID')
          get_tw_taxon_name_id = import.get('SFTaxonNameIDToTWTaxonNameID')
          get_tw_otu_id = import.get('SFTaxonNameIDToTWOtuID') # Note this is an OTU associated with a SF.TaxonNameID (probably a bad taxon name)
          get_taxon_name_otu_id = import.get('TWTaxonNameIDToOtuID') # Note this is the OTU offically associated with a real TW.taxon_name_id
          get_tw_source_id = import.get('SFRefIDToTWSourceID')
          get_sf_verbatim_ref = import.get('RefIDToVerbatimRef') # key is SF.RefID, value is verbatim string
          get_nomenclator_metadata = import.get('SFNomenclatorIDToSFNomenclatorMetadata')
          get_cvt_id = import.get('CvtProjUriID')
          get_containing_source_id = import.get('TWSourceIDToContainingSourceID') # use to determine if taxon_name_author must be created (orig desc only)
          get_sf_taxon_name_authors = import.get('SFRefIDToTaxonNameAuthors') # contains ordered array of SF.PersonIDs
          get_tw_person_id = import.get('SFPersonIDToTWPersonID')
          get_sf_file_id = import.get('SFTaxonNameIDToSFFileID')

          otu_not_found_array = []

          tw_taxa_ids = {} #12_Aus_bus -> TaxonName.id

          print "\nMaking list of taxa from the DB, 1st pass\n"
          i = 0
          Protonym.find_each do |t|
            i += 1
            print "\r#{i}"
            if t.rank_class.to_s == 'NomenclaturalRank::Iczn::GenusGroup::Genus' || t.rank_class.to_s == 'NomenclaturalRank::Iczn::GenusGroup::Subgenus'
              tw_taxa_ids[t.project_id.to_s + '_' + t.name] = t.id
            elsif t.rank_class.to_s == 'NomenclaturalRank::Iczn::SpeciesGroup::Species' || t.rank_class.to_s == 'NomenclaturalRank::Iczn::SpeciesGroup::Subspecies'
              tw_taxa_ids[t.project_id.to_s + '_' + t.ancestor_at_rank('genus').name + '_' + t.name] = t.id unless t.ancestor_at_rank('genus').nil?
              tw_taxa_ids[t.project_id.to_s + '_' + t.ancestor_at_rank('subgenus').name + '_' + t.name] = t.id unless t.ancestor_at_rank('subgenus').nil?
            end
          end
          print "\nMaking list of taxa from the DB, 2nd pass\n"
          i = 0
          Protonym.find_each do |t|
            i += 1
            print "\r#{i}"
            if t.rank_class.to_s == 'NomenclaturalRank::Iczn::GenusGroup::Genus' || t.rank_class.to_s == 'NomenclaturalRank::Iczn::GenusGroup::Subgenus'

            elsif t.rank_class.to_s == 'NomenclaturalRank::Iczn::SpeciesGroup::Species' || t.rank_class.to_s == 'NomenclaturalRank::Iczn::SpeciesGroup::Subspecies'
              tw_taxa_ids[t.project_id.to_s + '_' + t.original_genus.name + '_' + t.name] = t.id unless t.original_genus.nil?
              tw_taxa_ids[t.project_id.to_s + '_' + t.original_genus.name] = t.original_genus.id unless t.original_genus.nil?
            end
          end

          path = @args[:data_directory] + 'tblSpeciesNames.txt'
          print "\ntblSpeciesNames.txt\n"
          raise "file #{path} not found" if not File.exists?(path)
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

          # SpeciesNameID
          # FileID
          # Name
          # Italicize

          i = 0
          species_name_id = {}
          file.each do |row|
            i += 1
            print "\r#{i}"
            species_name_id[row['SpeciesNameID'].to_i] = [row['Name'].to_s, row['Italicize'].to_i]
          end

          path = @args[:data_directory] + 'tblGenusNames.txt'
          print "\ntblGenusNames.txt\n"
          raise "file #{path} not found" if not File.exists?(path)
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

          # GenusNameID
          # FileID
          # Name
          # Italicize

          i = 0
          genus_name_id = {}
          file.each do |row|
            i += 1
            print "\r#{i}"
            genus_name_id[row['GenusNameID'].to_i] = [row['Name'].to_s, row['Italicize'].to_i]
          end

          path = @args[:data_directory] + 'tblNomenclator.txt'
          print "\ntblNomenclator.txt\n"
          raise "file #{path} not found" if not File.exists?(path)
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

          # NomenclatorID
          # FileID
          # GenusNameID
          # SubgenusNameID
          # InfragenusNameID
          # SpeciesSeriesNameID
          # SpeciesGroupNameID
          # SpeciesSubgroupNameID
          # SpeciesNameID
          # SubspeciesNameID
          # InfrasubKind
          # InfrasubspeciesNameID
          # SuitableForRanks
          # IdentQualifier - ? or nr.
          # RankQualified
          # LastUpdate
          # ModifiedBy
          # CreatedOn
          # CreatedBy

          i = 0
          nomenclator_ids = {}
          file.each do |row|
            i += 1
            print "\r#{i}"
            a = {}
            a.merge!('genus' => genus_name_id[row['GenusNameID'].to_i]) unless row['GenusNameID'] == '0'
            a.merge!('subgenus' => genus_name_id[row['SubgenusNameID'].to_i]) unless row['SubgenusNameID'] == '0'
            a.merge!('species' => species_name_id[row['SpeciesNameID'].to_i]) unless row['SpeciesNameID'] == '0'
            a.merge!('subspecies' => species_name_id[row['SubspeciesNameID'].to_i]) unless row['SubspeciesNameID'] == '0'
            a.merge!('infrasubspecies' => species_name_id[row['InfrasubspeciesNameID'].to_i]) unless row['InfrasubspeciesNameID'] == '0'
            a.merge!('kind' => row['InfrasubKind']) unless row['InfrasubKind'] == '0'
            a.merge!('qualifier' => row['IdentQualifier']) unless row['IdentQualifier'] == '0'
            nomenclator_ids.merge!(row['NomenclatorID'].to_i => a)
          end

#          path = @args[:data_directory] + 'sfNomenclatorTaxonNameIDs.txt'

          # TaxonNameID
          # SeqNum
          # FileID
          # RefID
          # NomenclatorID
          # NomenclatorString
          # GenusTaxonNameID
          # SubgenusTaxonNameID
          # SpeciesSeriesTaxonNameID
          # SpeciesGroupTaxonNameID
          # SpeciesSubgroupTaxonNameID
          # SpeciesTaxonNameID
          # SubspeciesTaxonNameID

#          path = @args[:data_directory] + 'sfNomenclatorStrings.txt'

          # NomenclatorID
          # NomenclatorString
          # IdentQualifier
          # FileID

          count_found = 0
          error_counter = 0
          funny_exceptions_counter = 0
          cite_found_counter = 0
          otu_not_found_counter = 0
          orig_desc_source_id = 0 # make sure only first cite to original description is handled as such (when more than one cite to same source)
          otu_only_counter = 0
          new_combination_counter = 0
          total_combination_counter = 0
          source_used_counter = 0

          unique_bad_nomenclators = {}
          new_name_status = {1 => 0, # unchanged  # key = NewNameStatusID, value = count of instances, initialize keys 1 - 22 = 0 (some keys are missing)
                             2 => 0, # new name
                             3 => 0, # made synonym
                             4 => 0, # made valid or temporary
                             5 => 0, # new combination
                             6 => 0, # new nomen nudum
                             7 => 0, # nomen dubium
                             8 => 0, # missed previous change
                             9 => 0, # still synonym, but of different taxon
                             10 => 0, # gender change
                             17 => 0, # new corrected name
                             18 => 0, # different combination
                             19 => 0, # made valid in new combination
                             20 => 0, # incorrect name before correct
                             22 => 0} # misapplied name

          type_info = {1 => 0, # designate syntypes
                       2 => 0, # designate holotype
                       3 => 0, # designate lectotype
                       4 => 0, # designate neotype
                       5 => 0, # remove syntypes
                       6 => 0, # rulling by comission
                       7 => 0} # unspecified


          base_uri = 'http://speciesfile.org/legacy/'

          cites_id_done = {}
          ['', 'genus', 'subgenus', 'species', 'subspecies', 'infrasubspecies'].each do |rank_pass|

            path = @args[:data_directory] + 'tblCites.txt'
            print "\ntblCites.txt Working on: #{rank_pass}\n"
            raise "file #{path} not found" if not File.exists?(path)
            file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

            # TaxonNameID
            # SeqNum
            # RefID
            # CitePages
            # Note
            # NomenclatorID
            # NewNameStatusID
            # TypeInfoID
            # ConceptChangeID
            # CurrentConcept
            # InfoFlags
            # InfoFlagStatus
            # PolynomialStatus
            # LastUpdate
            # ModifiedBy
            # CreatedOn
            # CreatedBy
            # FileID


            i = 0
            file.each do |row|
              i += 1
              print "\r#{i}"
              next if cites_id_done[row['TaxonNameID'].to_s + '_' + row['SeqNum'].to_s]

              if excluded_taxa.include? row['TaxonNameID']
                cites_id_done[row['TaxonNameID'].to_s + '_' + row['SeqNum'].to_s] = true
                next
              end

              if skipped_file_ids.include? row['FileID'].to_i
                cites_id_done[row['TaxonNameID'].to_s + '_' + row['SeqNum'].to_s] = true
                next
              end

              taxon_name_id = get_tw_taxon_name_id[row['TaxonNameID']] # cannot to_i because if nil, nil.to_i = 0

              if taxon_name_id.nil?
                if get_tw_otu_id[row['TaxonNameID']]
                  logger.info "SF.TaxonNameID = #{row['TaxonNameID']} previously created as OTU (otu_only_counter = #{otu_only_counter += 1})"
                elsif otu_not_found_array.include? row['TaxonNameID'] # already in array (probably seqnum > 1)
                  logger.info "SF.TaxonNameID = #{row['TaxonNameID']} already in otu_not_found_array (total in otu_not_found_counter = #{otu_not_found_counter})"
                else
                  otu_not_found_array << row['TaxonNameID'] # add SF.TaxonNameID to otu_not_found_array
                  logger.info "SF.TaxonNameID = #{row['TaxonNameID']} added to otu_not_found_array (otu_not_found_counter = #{otu_not_found_counter += 1})"
                end
                cites_id_done[row['TaxonNameID'].to_s + '_' + row['SeqNum'].to_s] = true
                next
              end

              source_id = get_tw_source_id[row['RefID']].to_i
              if source_id == 0
                cites_id_done[row['TaxonNameID'].to_s + '_' + row['SeqNum'].to_s] = true
                next
              end

              a = []
              a += [nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0]] if nomenclator_ids[row['NomenclatorID'].to_i]['genus']
              a += [nomenclator_ids[row['NomenclatorID'].to_i]['subgenus'][0]] if nomenclator_ids[row['NomenclatorID'].to_i]['subgenus']
              a += [nomenclator_ids[row['NomenclatorID'].to_i]['species'][0]] if nomenclator_ids[row['NomenclatorID'].to_i]['species']
              a += [nomenclator_ids[row['NomenclatorID'].to_i]['subspecies'][0]] if nomenclator_ids[row['NomenclatorID'].to_i]['subspecies']
              a += [nomenclator_ids[row['NomenclatorID'].to_i]['infrasubspecies'][0]] if nomenclator_ids[row['NomenclatorID'].to_i]['infrasubspecies']
              nomenclator_string = a.compact.join('_')

              if row['NomenclatorID'] != '0'
                #nomenclator_string = get_nomenclator_metadata[row['NomenclatorID']]['nomenclator_string'].gsub('.  ', '. ') # delete 2nd space after period in var, form, etc.
                nomenclator_ident_qualifier = get_nomenclator_metadata[row['NomenclatorID']]['ident_qualifier']
                # row['FileID'] = get_nomenclator_metadata[row['NomenclatorID']]['file_id']
                unless nomenclator_ids[row['NomenclatorID'].to_i]['qualifier'].blank?
  #              if nomenclator_ident_qualifier.present? # has some irrelevant text in it
                  # logger.warn "No citation created because IdentQualifier has irrelevant data: (SF.FileID: #{row['FileID']}, SF.TaxonNameID: #{row['TaxonNameID']}, SF.RefID #{row['RefID']} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']})"
                  # create data attr on taxon_name

                  protonym = TaxonName.find(taxon_name_id)
                  project_id = protonym.project_id.to_s #  TaxonName.find(taxon_name_id).project_id.to_s # forced to string for hash value
                  Current.project_id = project_id
                  Note.create!(
                      note_object_type: protonym,
                      note_object_id: taxon_name_id,
                      text: "Citation to '#{get_sf_verbatim_ref[row['RefID']]}' not created because accompanying nomenclator ('#{nomenclator_string}') contains irrelevant data ('#{nomenclator_ident_qualifier}')",
                      project_id: project_id,
                      created_at: row['CreatedOn'], # housekeeping data from citation not created
                      updated_at: row['LastUpdate'],
                      created_by_id: get_tw_user_id[row['CreatedBy']],
                      updated_by_id: get_tw_user_id[row['ModifiedBy']]
                  )
                  cites_id_done[row['TaxonNameID'].to_s + '_' + row['SeqNum'].to_s] = true
                  next
                end
              end

              if rank_pass == '' && row['NomenclatorID'] != '0'
                next
              elsif rank_pass == 'genus' && (!nomenclator_ids[row['NomenclatorID'].to_i]['subgenus'].nil? || !nomenclator_ids[row['NomenclatorID'].to_i]['species'].nil? || !nomenclator_ids[row['NomenclatorID'].to_i]['subspecies'].nil? || !nomenclator_ids[row['NomenclatorID'].to_i]['infrasubspecies'].nil?)
                next
              elsif rank_pass == 'subgenus' && (!nomenclator_ids[row['NomenclatorID'].to_i]['species'].nil? || !nomenclator_ids[row['NomenclatorID'].to_i]['subspecies'].nil? || !nomenclator_ids[row['NomenclatorID'].to_i]['infrasubspecies'].nil?)
                next
              elsif rank_pass == 'species' && (!nomenclator_ids[row['NomenclatorID'].to_i]['subspecies'].nil? || !nomenclator_ids[row['NomenclatorID'].to_i]['infrasubspecies'].nil?)
                next
              elsif rank_pass == 'subspecies' && (!nomenclator_ids[row['NomenclatorID'].to_i]['infrasubspecies'].nil?)
                next
              end

              protonym = TaxonName.find(taxon_name_id)
              project_id = protonym.project_id.to_s #  TaxonName.find(taxon_name_id).project_id.to_s # forced to string for hash value
              Current.project_id = project_id.to_i

              if nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['genus'] && tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0]].nil?
                pr = Protonym.create(name: nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0], rank_class: Ranks.lookup(:iczn, 'Genus'), project_id: project_id, parent_id: protonym.root.id, created_by_id: get_tw_user_id[row['CreatedBy']], updated_by_id: get_tw_user_id[row['ModifiedBy']], created_at: row['CreatedOn'], updated_at: row['LastUpdate'])
                if pr.id.nil?
                  cites_id_done[row['TaxonNameID'].to_s + '_' + row['SeqNum'].to_s] = true
                  next
                end
                pr.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus', subject_taxon_name: pr, project_id: pr.id)
                pr.save
                tw_taxa_ids[project_id + '_' + pr.name] = pr.id if tw_taxa_ids[project_id + '_' + pr.name].nil?
                if nomenclator_ids[row['NomenclatorID'].to_i]['subgenus'].nil? && nomenclator_ids[row['NomenclatorID'].to_i]['species'].nil? && nomenclator_ids[row['NomenclatorID'].to_i]['subspecies'].nil? && nomenclator_ids[row['NomenclatorID'].to_i]['infrasubspecies'].nil?
                  pr.parent_id = protonym.parent_id
                  pr.rank_class = protonym.rank_class
                  pr.save
                  pr.taxon_name_relationships.create(object_taxon_name: protonym, type: 'TaxonNameRelationship::Iczn::Invalidating', project_id: project_id)
                end
              end
              if nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['subgenus'] && tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['subgenus'][0]].nil?
                pr = Protonym.create(name: nomenclator_ids[row['NomenclatorID'].to_i]['subgenus'][0], rank_class: Ranks.lookup(:iczn, 'Subgenus'), project_id: project_id, parent_id: protonym.root.id, created_by_id: get_tw_user_id[row['CreatedBy']], updated_by_id: get_tw_user_id[row['ModifiedBy']], created_at: row['CreatedOn'], updated_at: row['LastUpdate'])
                if pr.id.nil?
                  cites_id_done[row['TaxonNameID'].to_s + '_' + row['SeqNum'].to_s] = true
                  next
                end
                pr.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus', subject_taxon_name: pr, project_id: project_id)
                pr.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0]]), project_id: project_id) if nomenclator_ids[row['NomenclatorID'].to_i]['genus'] && pr.original_genus.nil?
                pr.save
                tw_taxa_ids[project_id + '_' + pr.name] = pr.id
                if nomenclator_ids[row['NomenclatorID'].to_i]['species'].nil? && nomenclator_ids[row['NomenclatorID'].to_i]['subspecies'].nil? && nomenclator_ids[row['NomenclatorID'].to_i]['infrasubspecies'].nil?
                  tw_taxa_ids[project_id + '_' + nomenclator_string] = pr.id if tw_taxa_ids[project_id + '_' + nomenclator_string].nil?
                  pr.parent_id = protonym.parent_id
                  pr.rank_class = protonym.rank_class
                  pr.save
                  pr.taxon_name_relationships.create(object_taxon_name: protonym, type: 'TaxonNameRelationship::Iczn::Invalidating', project_id: project_id)
                end
              end
              if  nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['species'] && nomenclator_ids[row['NomenclatorID'].to_i]['genus'] && protonym && tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0] + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['species'][0]].nil?
                pr = Protonym.create(name: nomenclator_ids[row['NomenclatorID'].to_i]['species'][0], rank_class: Ranks.lookup(:iczn, 'Species'), project_id: project_id, parent_id: protonym.root.id, created_by_id: get_tw_user_id[row['CreatedBy']], updated_by_id: get_tw_user_id[row['ModifiedBy']], created_at: row['CreatedOn'], updated_at: row['LastUpdate'])
                if pr.id.nil?
                  cites_id_done[row['TaxonNameID'].to_s + '_' + row['SeqNum'].to_s] = true
                  next
                end
                pr.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSpecies', subject_taxon_name: pr, project_id: project_id)
                pr.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['subgenus'][0]]), project_id: project_id) if nomenclator_ids[row['NomenclatorID'].to_i]['subgenus']
                pr.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0]]), project_id: project_id) if nomenclator_ids[row['NomenclatorID'].to_i]['genus'] && pr.original_genus.nil?
                pr.save
                tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0] + '_' + pr.name] = pr.id if tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0] + '_' + pr.name].nil?
                if nomenclator_ids[row['NomenclatorID'].to_i]['subspecies'].nil? && nomenclator_ids[row['NomenclatorID'].to_i]['infrasubspecies'].nil?
                  tw_taxa_ids[project_id + '_' + nomenclator_string] = pr.id if tw_taxa_ids[project_id + '_' + nomenclator_string].nil?
                  pr.parent_id = protonym.parent_id
                  pr.rank_class = protonym.rank_class
                  pr.save
                  pr.taxon_name_relationships.create(object_taxon_name: protonym, type: 'TaxonNameRelationship::Iczn::Invalidating', project_id: project_id)
                end
              end
              if nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['subspecies'] && nomenclator_ids[row['NomenclatorID'].to_i]['genus'] && protonym && tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0] + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['subspecies'][0]].nil?
                pr = Protonym.create(name: nomenclator_ids[row['NomenclatorID'].to_i]['subspecies'][0], rank_class: Ranks.lookup(:iczn, 'Subspecies'), project_id: project_id, parent_id: protonym.root.id, created_by_id: get_tw_user_id[row['CreatedBy']], updated_by_id: get_tw_user_id[row['ModifiedBy']], created_at: row['CreatedOn'], updated_at: row['LastUpdate'])
                if pr.id.nil?
                  cites_id_done[row['TaxonNameID'].to_s + '_' + row['SeqNum'].to_s] = true
                  next
                end
                pr.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSubspecies', subject_taxon_name: pr, project_id: project_id)
                pr.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSpecies', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0] + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['species'][0]]), project_id: project_id)  if nomenclator_ids[row['NomenclatorID'].to_i]['species']
                pr.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['subgenus'][0]]), project_id: project_id) if nomenclator_ids[row['NomenclatorID'].to_i]['subgenus']
                pr.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0]]), project_id: project_id) if nomenclator_ids[row['NomenclatorID'].to_i]['genus'] && pr.original_genus.nil?
                pr.save
                tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0] + '_' + pr.name] = pr.id if tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0] + '_' + pr.name].nil?
                if nomenclator_ids[row['NomenclatorID'].to_i]['infrasubspecies'].nil?
                  tw_taxa_ids[project_id + '_' + nomenclator_string] = pr.id if tw_taxa_ids[project_id + '_' + nomenclator_string].nil?
                  pr.parent_id = protonym.parent_id
                  pr.rank_class = protonym.rank_class
                  pr.save
                  pr.taxon_name_relationships.create(object_taxon_name: protonym, type: 'TaxonNameRelationship::Iczn::Invalidating', project_id: project_id)
                end
              end

              #logger.info "Working with TW.project_id: #{project_id}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{taxon_name_id}, SF.RefID #{row['RefID']} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']} (count #{count_found += 1}) \n"

              #cite_pages = row['CitePages']

              new_name_uri = (base_uri + 'new_name_status/' + row['NewNameStatusID']) unless row['NewNameStatusID'] == '0'
              type_info_uri = (base_uri + 'type_info/' + row['TypeInfoID']) unless row['TypeInfoID'] == '0'
              info_flag_status_uri = (base_uri + 'info_flag_status/' + row['InfoFlagStatus']) unless row['InfoFlagStatus'] == '0'

              new_name_cvt_id = get_cvt_id[project_id][new_name_uri]
              type_info_cvt_id = get_cvt_id[project_id][type_info_uri]
              info_flag_status_cvt_id = get_cvt_id[project_id][info_flag_status_uri]

              # ap "NewNameStatusID = #{new_name_cvt_id.to_s}; TypeInfoID = #{type_info_cvt_id.to_s}" # if new_name_cvt_id

              is_original = false

              # Original description citation most likely already exists but pages are source pages, not cite pages
              citation = Citation.where(source_id: source_id, citation_object_type: 'TaxonName', citation_object_id: taxon_name_id, is_original: true).first


              if source_id.nil?
#                if citation.nil?
                next
              elsif !citation.nil? && citation.pages.blank? && orig_desc_source_id != source_id
                orig_desc_source_id = source_id # prevents duplicate citation to same source being processed as original description
                #citation.notes.create(text: row['Note'], project_id: project_id, created_by_id: get_tw_user_id[row['CreatedBy']], updated_by_id: get_tw_user_id[row['ModifiedBy']], created_at: row['CreatedOn'], updated_at: row['LastUpdate']) unless row['Note'].blank?

                citation.update(pages: row['CitePages'])
                unless row['Note'].blank?
                  n = protonym.notes.find_or_create_by(text: row['Note'], project_id: project_id, created_at: row['CreatedOn'], updated_at: row['LastUpdate'], created_by_id: get_tw_user_id[row['CreatedBy']], updated_by_id: get_tw_user_id[row['ModifiedBy']])
                  # n.citations.create!(source_id: citation.source_id, project_id: project_id, created_at: row['CreatedOn'], updated_at: row['LastUpdate'], created_by_id: get_tw_user_id[row['CreatedBy']], updated_by_id: get_tw_user_id[row['ModifiedBy']])
                end
                unless new_name_cvt_id.blank?
                  n = protonym.tags.find_or_create_by(keyword_id: new_name_cvt_id, project_id: project_id, created_by_id: get_tw_user_id[row['CreatedBy']], updated_by_id: get_tw_user_id[row['ModifiedBy']], created_at: row['CreatedOn'], updated_at: row['LastUpdate'])
                  #n.citations.create!(source_id: citation.source_id, project_id: project_id)
                end
                is_original = true
                unless type_info_cvt_id.blank?
                  n = protonym.tags.find_or_create_by(keyword_id: type_info_cvt_id, project_id: project_id, created_by_id: get_tw_user_id[row['CreatedBy']], updated_by_id: get_tw_user_id[row['ModifiedBy']], created_at: row['CreatedOn'], updated_at: row['LastUpdate'])
                  #n.citations.create!(source_id: citation.source_id, project_id: project_id)
                end
                unless info_flag_status_cvt_id.blank?
                  n = protonym.confidences.find_or_create_by(confidence_level_id: info_flag_status_cvt_id, project_id: project_id, created_by_id: get_tw_user_id[row['CreatedBy']], updated_by_id: get_tw_user_id[row['ModifiedBy']], created_at: row['CreatedOn'], updated_at: row['LastUpdate'])
                  #n.citations.create!(source_id: citation.source_id, project_id: project_id)
                end

                # logger.info "Citation found: citation.id = #{citation.id}, taxon_name_id = #{taxon_name_id}, cite_pages = '#{row['CitePages']}' (cite_found_counter = #{cite_found_counter += 1})"

                if get_containing_source_id[source_id.to_s] && protonym.roles.nil? # create taxon_name_author role for contained Refs only
                  Source.find(get_containing_source_id[source_id.to_s].to_i).roles.each do |person|
#                    get_sf_taxon_name_authors[row['RefID']].each do |sf_person_id| # person_id from author_array
                    protonym.roles.create!(
#                        person_id: get_tw_person_id[sf_person_id],
                        person: person,
                        type: 'TaxonNameAuthor',
                        project_id: project_id, # role is project_role
                        )
                  end
                end

                if rank_pass == 'genus' && nomenclator_ids[row['NomenclatorID'].to_i]['genus'] && protonym.name == nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0]
                  protonym.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus', subject_taxon_name: protonym, project_id: project_id) && protonym.original_genus.nil?
                elsif rank_pass == 'subgenus' && nomenclator_ids[row['NomenclatorID'].to_i]['subgenus'] && protonym.name == nomenclator_ids[row['NomenclatorID'].to_i]['subgenus'][0]
                  protonym.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus', subject_taxon_name: protonym, project_id: project_id)
                  protonym.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0]]), project_id: project_id) if protonym.original_genus.nil? && nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['genus'] && protonym.original_genus.nil?
                elsif rank_pass == 'species' && nomenclator_ids[row['NomenclatorID'].to_i]['species'] && protonym.name == nomenclator_ids[row['NomenclatorID'].to_i]['species'][0]
                  protonym.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSpecies', subject_taxon_name: protonym, project_id: project_id)
                  protonym.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['subgenus'][0]]), project_id: project_id) if nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['subgenus']
                  protonym.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0]]), project_id: project_id) if protonym.original_genus.nil? && nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['genus'] && protonym.original_genus.nil?
                elsif rank_pass == 'subspecies' && nomenclator_ids[row['NomenclatorID'].to_i]['subspecies'] && protonym.name == nomenclator_ids[row['NomenclatorID'].to_i]['subspecies'][0]
                  protonym.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSubspecies', subject_taxon_name: protonym, project_id: project_id)
                  protonym.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSpecies', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0] + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['species'][0]]), project_id: project_id) if nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['genus'] && nomenclator_ids[row['NomenclatorID'].to_i]['species']
                  protonym.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['subgenus'][0]]), project_id: project_id) if nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['subgenus']
                  protonym.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0]]), project_id: project_id) if protonym.original_genus.nil? && nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['genus'] && protonym.original_genus.nil?
                elsif rank_pass == 'infrasubspecies' && nomenclator_ids[row['NomenclatorID'].to_i]['infrasubspecies'] && protonym.name == nomenclator_ids[row['NomenclatorID'].to_i]['infrasubspecies'][0]
                  if nomenclator_ids[row['NomenclatorID'].to_i]['kind'] == '0'
                    protonym.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalForm', subject_taxon_name: protonym, project_id: project_id)
                  elsif nomenclator_ids[row['NomenclatorID'].to_i]['kind'] == '1'
                    protonym.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalVariety', subject_taxon_name: protonym, project_id: project_id)
                  elsif ['2', '3'].include?(nomenclator_ids[row['NomenclatorID'].to_i]['kind'])
                    protonym.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalVariety', subject_taxon_name: protonym, project_id: project_id)
                    protonym.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::Excluded::Infrasubspecific')
                  end
                  protonym.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSubspecies', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0] + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['subspecies'][0]]), project_id: project_id) if nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['genus'] && nomenclator_ids[row['NomenclatorID'].to_i]['subspecies']
                  protonym.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSpecies', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0] + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['species'][0]]), project_id: project_id) if nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['genus'] && nomenclator_ids[row['NomenclatorID'].to_i]['species']
                  protonym.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['subgenus'][0]]), project_id: project_id) if nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['subgenus']
                  protonym.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0]]), project_id: project_id) if protonym.original_genus.nil? && nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['genus'] && protonym.original_genus.nil?
                end
                protonym.save
                #string = [project_id, protonym.original_genus.try(:name), protonym.original_subgenus.try(:name), protonym.original_species.try(:name), protonym.original_subspecies.try(:name), protonym.original_variety.try(:name), protonym.original_form.try(:name)].compact.join('_')
                tw_taxa_ids[project_id + '_' + nomenclator_string] = protonym.id if tw_taxa_ids[project_id + '_' + nomenclator_string].nil?
                cites_id_done[row['TaxonNameID'].to_s + '_' + row['SeqNum'].to_s] = true
                next
              elsif row['NomenclatorID'] == '0'
                # no nomenclator data.
              elsif tw_taxa_ids[project_id + '_' + nomenclator_string]
                # just create another citation
                if rank_pass == 'genus' && nomenclator_ids[row['NomenclatorID'].to_i]['genus'] && nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0] == protonym.name
                else
                  taxon_name_id = tw_taxa_ids[project_id + '_' + nomenclator_string]
                  protonym = TaxonName.find(taxon_name_id)
                end
              else
                p = Protonym.new(project_id: project_id)
                if rank_pass == 'genus'
                  next unless nomenclator_ids[row['NomenclatorID'].to_i]['genus']
                  p.name = nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0]
                  p.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus', subject_taxon_name: p, project_id: p.id)
                elsif rank_pass == 'subgenus'
                  next unless nomenclator_ids[row['NomenclatorID'].to_i]['subgenus']
                  p.name = nomenclator_ids[row['NomenclatorID'].to_i]['subgenus'][0]
                  p.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus', subject_taxon_name: p, project_id: p.id)
                  p.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0]]), project_id: project_id) if nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['genus']
                elsif rank_pass == 'species'
                  next unless nomenclator_ids[row['NomenclatorID'].to_i]['species']
                  p.name = nomenclator_ids[row['NomenclatorID'].to_i]['species'][0]
                  p.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSpecies', subject_taxon_name: p, project_id: p.id)
                  p.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['subgenus'][0]]), project_id: project_id) if nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['subgenus']
                  p.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0]]), project_id: project_id) if nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['genus']
                elsif rank_pass == 'subspecies'
                  next unless nomenclator_ids[row['NomenclatorID'].to_i]['subspecies']
                  p.name = nomenclator_ids[row['NomenclatorID'].to_i]['subspecies'][0]
                  p.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSubspecies', subject_taxon_name: p, project_id: p.id)
                  p.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSpecies', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0] + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['species'][0]]), project_id: project_id) if nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['genus'] && nomenclator_ids[row['NomenclatorID'].to_i]['species']
                  p.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['subgenus'][0]]), project_id: project_id) if nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['subgenus']
                  p.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0]]), project_id: project_id) if nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['genus']
                elsif rank_pass == 'infrasubspecies'
                  next unless nomenclator_ids[row['NomenclatorID'].to_i]['infrasubspecies']
                  p.name = nomenclator_ids[row['NomenclatorID'].to_i]['infrasubspecies'][0]
                  if nomenclator_ids[row['NomenclatorID'].to_i]['kind'] == '0'
                    p.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalForm', subject_taxon_name: p, project_id: p.id)
                  elsif nomenclator_ids[row['NomenclatorID'].to_i]['kind'] == '1'
                    p.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalVariety', subject_taxon_name: p, project_id: p.id)
                  elsif ['2', '3'].include?(nomenclator_ids[row['NomenclatorID'].to_i]['kind'])
                    p.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalVariety', subject_taxon_name: p, project_id: p.id)
                    p.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::Excluded::Infrasubspecific')
                  end
                  p.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSubspecies', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0] + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['subspecies'][0]]), project_id: project_id) if nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['genus'] && nomenclator_ids[row['NomenclatorID'].to_i]['subspecies']
                  p.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSpecies', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0] + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['species'][0]]), project_id: project_id) if nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['genus'] && nomenclator_ids[row['NomenclatorID'].to_i]['species']
                  p.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['subgenus'][0]]), project_id: project_id) if nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['subgenus']
                  p.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0]]), project_id: project_id) if protonym.original_genus.nil? && nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['genus']
                end
                p.created_at = row['CreatedOn']
                p.updated_at = row['LastUpdate']
                p.created_by_id = get_tw_user_id[row['CreatedBy']]
                p.updated_by_id = get_tw_user_id[row['ModifiedBy']]
                p.parent_id = protonym.parent_id
                p.rank_class = protonym.rank_class
                p.save
                next if p.id.nil?
                p.taxon_name_relationships.create(object_taxon_name: protonym, type: 'TaxonNameRelationship::Iczn::Invalidating', project_id: project_id)
                p.taxon_name_classifications.create(type: 'TaxonNameClassification::Iczn::Unavailable::NomenNudum', project_id: project_id) if row['NewNameStatusID'] == '6'
                p.taxon_name_classifications.create(type: 'TaxonNameClassification::Iczn::Available::Valid::NomenDubium', project_id: project_id) if row['NewNameStatusID'] == '7'

                cites_id_done[row['TaxonNameID'].to_s + '_' + row['SeqNum'].to_s] = true
                tw_taxa_ids[project_id + '_' + nomenclator_string] = p.id if tw_taxa_ids[project_id + '_' + nomenclator_string].nil?
                protonym = p
                taxon_name_id = p.id
              end

              unless is_original
                citation = Citation.new(
                        source_id: source_id,
                        pages: row['CitePages'],
                        is_original: (row['SeqNum'] == '1' ? true : false),
                        citation_object: protonym,
                        project_id: project_id,
                        created_at: row['CreatedOn'],
                        updated_at: row['LastUpdate'],
                        created_by_id: get_tw_user_id[row['CreatedBy']],
                        updated_by_id: get_tw_user_id[row['ModifiedBy']]
                )

                begin
                  citation.save
                  unless row['Note'].blank?
                    n = protonym.notes.find_or_create_by(text: row['Note'], project_id: project_id)
                    #n.citations.create!(source_id: citation.source_id, project_id: project_id, created_at: row['CreatedOn'], updated_at: row['LastUpdate'], created_by_id: get_tw_user_id[row['CreatedBy']], updated_by_id: get_tw_user_id[row['ModifiedBy']])
                  end
                  unless new_name_cvt_id.blank?
                    n = protonym.tags.find_or_create_by(keyword_id: new_name_cvt_id, project_id: project_id)
                    byebug if n.id.nil?
                    #n.citations.create!(source_id: citation.source_id, project_id: project_id)
                  end
                  unless type_info_cvt_id.blank?
                    n = protonym.tags.find_or_create_by(keyword_id: type_info_cvt_id, project_id: project_id)
                    byebug if n.id.nil?
                    #n.citations.create!(source_id: citation.source_id, project_id: project_id)
                  end
                  unless info_flag_status_cvt_id.blank?
                    n = protonym.confidences.find_or_create_by(confidence_level_id: info_flag_status_cvt_id, project_id: project_id)
                    byebug if n.id.nil?
#                    n.citations.create!(source_id: citation.source_id, project_id: project_id)
                  end
                rescue ActiveRecord::RecordInvalid # citation not valid


                  # yes I know this is ugly but it works
                  if citation.errors.messages[:source_id].nil?
                    logger.error "Citation ERROR [TW.project_id: #{project_id}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{protonym.id}, SF.RefID #{row['RefID']} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']}] (#{error_counter += 1}): " + citation.errors.full_messages.join(';')
                    next
                  else # make pages unique and save again
                    if citation.errors.messages[:source_id].include?('has already been taken') # citation.errors.messages[:source_id][0] == 'has already been taken'
                      citation.pages = "#{row['CitePages']} [dupl #{row['SeqNum']}"
                      begin
                        citation.save
                      rescue ActiveRecord::RecordInvalid
                        # [ERROR]2018-03-30 17:09:43.127: Citation ERROR [TW.project_id: 11, SF.TaxonNameID 1152999 = TW.taxon_name_id 47338, SF.RefID 16047 = TW.source_id 12047, SF.SeqNum 2, nomenclator_string = Limnoperla jaffueli, name_status = 3] (total_error_counter = 1, source_used_counter = 1): Source has already been taken
                        logger.error "Citation ERROR [TW.project_id: #{project_id}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{protonym.id}, SF.RefID #{row['RefID']} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']}, nomenclator_string = #{nomenclator_string}, name_status = #{row['NewNameStatusID']}], (current_error_counter = #{error_counter += 1}, source_used_counter = #{source_used_counter += 1}): " + citation.errors.full_messages.join(';')
                        logger.info "NewNameStatusID = #{row['NewNameStatusID']}, count = #{new_name_status[row['NewNameStatusID'].to_i] += 1}"
                        next
                      end
                    else # citation error was not already been taken (other validation failure)
                      logger.error "Citation ERROR [TW.project_id: #{project_id}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{protonym.id}, SF.RefID #{row['RefID']} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']}] (#{error_counter += 1}): " + citation.errors.full_messages.join(';')
                      next
                    end
                  end
                end
              end


              ### After citation updated or created
              ## Nomenclator: DataAttribute of citation, NomenclatorID > 0
#
#              if nomenclator_string # OR could value: be evaluated below based on NomenclatorID?
#                da = DataAttribute.new(type: 'ImportAttribute',
#                                       # attribute_subject_id: citation.id,
#                                       # attribute_subject_type: 'Citation',
#                                       attribute_subject: citation, # replaces two lines above
#                                       import_predicate: 'Nomenclator',
#                                       value: "#{nomenclator_string} (TW.project_id: #{project_id}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{taxon_name_id}, SF.RefID #{row['RefID']} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']})",
#                                       project_id: project_id,
#                                       created_at: row['CreatedOn'],
#                                       updated_at: row['LastUpdate'],
#                                       created_by_id: get_tw_user_id[row['CreatedBy']],
#                                       updated_by_id: get_tw_user_id[row['ModifiedBy']]
#                )
#                begin
#                  da.save
#                    # puts 'DataAttribute Nomenclator created'
#                rescue ActiveRecord::RecordInvalid # da not valid
#                  logger.error "DataAttribute Nomenclator ERROR NomenclatorID = #{row['NomenclatorID']}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{taxon_name_id} (error_counter = #{error_counter += 1}): " + da.errors.full_messages.join(';')
#                end
#              end

              ## ConceptChange: For now, do not import, only 2000 out of 31K were not automatically calculated, downstream in TW we will use Euler
              ## CurrentConcept: bit: For now, do not import
              # select * from tblCites c inner join tblTaxa t on c.TaxonNameID = t.TaxonNameID where c.CurrentConcept = 1 and t.NameStatus = 7
              ## InfoFlags: Attribute/topic of citation?!! Treat like StatusFlags for individual values
              # Use as topics on citations for OTUs, make duplicate citation on OTU, then topic on that citation

              info_flags = row['InfoFlags'].to_i
              if info_flags == 0
                next
              end

              # !! from here on we're back to referencing OTUs that were created PRE combination world
              otu_id = get_taxon_name_otu_id[protonym.id.to_s].to_i

              if otu_id == 0
                logger.warn "OTU error, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{protonym.id} (OTU not found: #{otu_not_found_counter += 1})"
                next
              end

              base_cite_info_flags_uri = (base_uri + 'cite_info_flags/') # + bit_position below
              cite_info_flags_array = Utilities::Numbers.get_bits(info_flags)

              citation_topics_attributes = cite_info_flags_array.collect {|bit_position|
                {topic_id: get_cvt_id[project_id][base_cite_info_flags_uri + bit_position.to_s],
                 project_id: project_id,
                 created_at: row['CreatedOn'],
                 updated_at: row['LastUpdate'],
                 created_by_id: get_tw_user_id[row['CreatedBy']],
                 updated_by_id: get_tw_user_id[row['ModifiedBy']]
                }
              }

              otu_citation = Citation.new(
                  source_id: source_id,
                  pages: row['CitePages'],
                  is_original: (row['SeqNum'] == '1' ? true : false),
                  citation_object_type: 'Otu',
                  citation_object_id: otu_id,
                  citation_topics_attributes: citation_topics_attributes,
                  project_id: project_id,
                  created_at: row['CreatedOn'],
                  updated_at: row['LastUpdate'],
                  created_by_id: get_tw_user_id[row['CreatedBy']],
                  updated_by_id: get_tw_user_id[row['ModifiedBy']]
              )

              begin
                otu_citation.save!
                puts 'OTU citation created'
              rescue ActiveRecord::RecordInvalid
                logger.error "OTU citation ERROR SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{protonym.id} = otu_id #{otu_id} (error_counter = #{error_counter += 1}): " + otu_citation.errors.full_messages.join(';')
              end

              ## PolynomialStatus: based on NewNameStatus: Used to detect "fake" (previous combos) synonyms
              # Not included in initial import; after import, in TW, when we calculate CoL output derived from OTUs, and if CoL output is clearly wrong then revisit this issue
            end
          end # genus, subgenus, species, subspecies






        # logger.info "total funny exceptions = '#{funny_exceptions_counter}', total unique_bad_nomenclators = '#{unique_bad_nomenclators.count}', \n unique_bad_nomenclators = '#{unique_bad_nomenclators}'"
          # ap "total funny exceptions = '#{funny_exceptions_counter}', total unique_bad_nomenclators = '#{unique_bad_nomenclators.count}', \n unique_bad_nomenclators = '#{unique_bad_nomenclators}'"
          puts 'new_name_status hash:'
          ap new_name_status
        end

        ################################################################################################# Nomenclator Fixes
        desc 'time rake tw:project_import:sf_import:citations:create_citations_fixes user_id=1 data_directory=/Users/proceps/src/sf/import/onedb2tw/working/'
        LoggedTask.define create_citations_fixes: [:data_directory, :environment, :user_id] do |logger|
          @proceps = User.where(email: 'arboridia@gmail.com').first

          Current.user_id = @proceps.id
          import = Import.find_or_create_by(name: 'SpeciesFileData')
          skipped_file_ids = import.get('SkippedFileIDs')
          get_tw_project_id = import.get('SFFileIDToTWProjectID')

          get_tw_project_id.each do |key, value|
            if skipped_file_ids.include? value.to_i
              next
            end
            print "\nApply fixes for the project #{value} \n"
            invalid_relationship_remove_sf(value.to_i)
          end
          get_tw_project_id.each do |key, value|
            if skipped_file_ids.include? value.to_i
              next
            end
            print "\nSoft validations for the project #{value} \n"
            soft_validations_sf(value.to_i)
          end
        end

        def invalid_relationship_remove_sf(project_id)

          fixed = 0
          combinations = 0
          i = 0
          Current.project_id = project_id

          j = 0
          print "\nHandling Invalid relationships: synonyms of synonyms\n"
          tr = TaxonNameRelationship.where(project_id: project_id).with_type_array(TAXON_NAME_RELATIONSHIP_NAMES_SYNONYM)
          tr.each do |t|
            j += 1

            print "\r#{j}    Fixes applied: #{fixed}   "
            s = t.subject_taxon_name
            o = t.object_taxon_name
            sval = s.valid_taxon_name

            if o.rank_string =~ /Family/
              if o.id != sval.id && o.cached_primary_homonym_alternative_spelling == sval.cached_primary_homonym_alternative_spelling
                t.object_taxon_name = sval
                t.save
                s.save
                fixed += 1
              end
              if s.cached_primary_homonym_alternative_spelling != o.cached_primary_homonym_alternative_spelling && s.origin_citation.nil?
                Protonym.where(project_id: project_id, cached_valid_taxon_name_id: sval.id, cached_primary_homonym_alternative_spelling: s.cached_primary_homonym_alternative_spelling).not_self(s).each do |p|
                  if !p.origin_citation.nil?
                    t.object_taxon_name = p
                    t.save
                    s.save
                    fixed += 1
                  end
                end

              end
            else
              if o.id != sval.id && o.cached_secondary_homonym_alternative_spelling == sval.cached_secondary_homonym_alternative_spelling
                t.object_taxon_name = sval
                t.save
                s.save
                fixed += 1
              end
              if s.cached_secondary_homonym_alternative_spelling != o.cached_secondary_homonym_alternative_spelling && s.origin_citation.nil?
                Protonym.where(project_id: project_id, cached_valid_taxon_name_id: sval.id, cached_secondary_homonym_alternative_spelling: s.cached_secondary_homonym_alternative_spelling).not_self(s).each do |p|
                  if !p.origin_citation.nil?
                    t.object_taxon_name = p
                    t.save
                    s.save
                    fixed += 1
                  end
                end
              end
            end

          end

          print "\nHandling Invalid relationships: synonyms to combinations. Project: #{project_id}\n"

          TaxonNameRelationship.where(project_id: project_id).with_type_string('TaxonNameRelationship::Iczn::Invalidating').each do |t|
            i += 1
            print "\r#{i}    Fixes applied: #{fixed}    Combinations created: #{combinations}"
            if t.citations.empty?
              created_at = t.created_at
              updated_at = t.updated_at
              created_by_id = t.created_by_id
              updated_by_id = t.updated_by_id

              s = t.subject_taxon_name
              svalid = s.cached_valid_taxon_name_id
              o = t.object_taxon_name
              shas = s.cached_secondary_homonym_alternative_spelling
              r = TaxonNameRelationship.where(project_id: project_id, object_taxon_name_id: s.id).with_type_base('TaxonNameRelationship::Iczn::Invalidating')
              r2 = TaxonNameRelationship.where(project_id: project_id, subject_taxon_name_id: s.id).with_type_base('TaxonNameRelationship::Iczn::Invalidating').count

              if s.taxon_name_classifications.empty? && r.empty?
                t.destroy
                s.save
                if o.rank_string =~ /Family/ && s.cached_primary_homonym_alternative_spelling == o.cached_primary_homonym_alternative_spelling && r2 == 1
                  TaxonNameRelationship.create!(subject_taxon_name: s, object_taxon_name: o, type: 'TaxonNameRelationship::Iczn::Invalidating::Usage::FamilyGroupNameForm')
                  fixed += 1
                elsif  o.rank_string =~ /Species/ && !s.original_combination_source.nil? && s.original_combination_source == o.original_combination_source && s.cached_primary_homonym_alternative_spelling == o.cached_primary_homonym_alternative_spelling && r2 == 1
                  TaxonNameRelationship.create!(subject_taxon_name: s, object_taxon_name: o, type: 'TaxonNameRelationship::Iczn::Invalidating::Usage::IncorrectOriginalSpelling')
                  fixed += 1
                elsif (o.rank_string =~ /Species/  && shas == o.cached_secondary_homonym_alternative_spelling && r2 == 1) ||
                    (o.rank_string =~ /Genus/  && s.cached_primary_homonym_alternative_spelling == o.cached_primary_homonym_alternative_spelling && r2 == 1)
                  combinations += 1
                  byebug if s.type != 'Protonym'
                  genus = s.original_genus
                  subgenus = s.original_subgenus
                  species = s.original_species
                  subspecies = s.original_subspecies
                  variety = s.original_variety
                  form = s.original_form
                  vname = s.cached_original_combination.to_s.gsub('<i>', '').gsub('</i>', '')
                  s.original_genus_relationship.destroy unless genus.blank?
                  s.original_subgenus_relationship.destroy unless subgenus.blank?
                  s.original_species_relationship.destroy unless species.blank?
                  s.original_subspecies_relationship.destroy unless subspecies.blank?
                  s.original_variety_relationship.destroy unless variety.blank?
                  s.original_form_relationship.destroy unless form.blank?
                  s.parent_id = nil
                  s.year_of_publication = nil
                  s.verbatim_author = nil
                  s.rank_class = nil
                  s.cached_html = nil
                  s.cached_author_year = nil
                  s.cached_original_combination_html = nil
                  s.cached_secondary_homonym = nil
                  s.cached_primary_homonym = nil
                  s.cached_secondary_homonym_alternative_spelling = nil
                  s.cached_primary_homonym_alternative_spelling = nil
                  s.cached = nil
                  s.cached_original_combination = nil
                  s.type = 'Combination'
                  s = s.becomes(Combination)
                  s.genus = genus unless genus.nil?
                  s.subgenus = subgenus unless subgenus.nil?
                  s.species = species unless species.nil?
                  s.subspecies = subspecies unless subspecies.nil?
                  s.variety = variety unless variety.nil?
                  s.form = form unless form.nil?
                  s.verbatim_name = vname
                  if !s.form.nil?
                    s.form = o
                  elsif !s.variety.nil?
                    s.variety = o
                  elsif !s.subspecies.nil?
                    s.subspecies = o
                  elsif !s.species.nil?
                    s.species = o
                  elsif !s.subgenus.nil?
                    s.subgenus = o
                  elsif !s.genus.nil?
                    s.genus = o
                  end
                  s.save
                  if !s.valid?
                    s = Protonym.find(s.id)
                    TaxonNameRelationship.create!(subject_taxon_name: s, object_taxon_name: o, type: 'TaxonNameRelationship::Iczn::Invalidating', project_id: project_id)
                    s.original_genus = genus unless genus.nil?
                    s.original_subgenus = subgenus unless subgenus.nil?
                    s.original_species = species unless species.nil?
                    s.original_subspecies = subspecies unless subspecies.nil?
                    s.original_variety = variety unless variety.nil?
                    s.original_form = form unless form.nil?
                  else
                    TaxonNameRelationship.where(project_id: project_id, subject_taxon_name_id: s.id).with_type_contains('Combination').each do |z|
                      z.object_taxon_name.verbatim_name = z.object_taxon_name.cached if z.object_taxon_name.type = 'Combination' && z.object_taxon_name.verbatim_name.blank?
                      z.subject_taxon_name_id = o.id
                      z.save
                      z.subject_taxon_name.save
                      fixed += 1
                    end
                    TaxonNameRelationship.where(project_id: project_id, subject_taxon_name_id: s.id).select{|i| i.type !~ /Combination/}.each do |z|
                      z.subject_taxon_name_id = o.id
                      z.save
                      fixed += 1
                    end
                    TaxonNameRelationship.where(project_id: project_id, subject_taxon_name_id: s.id).select{|i| i.type =~ /Combination/}.each do |z|
                      z.object_taxon_name.verbatim_name = z.object_taxon_name.cached if z.object_taxon_name.type = 'Combination' && z.object_taxon_name.verbatim_name.blank?
                      z.subject_taxon_name_id = o.id
                      z.save
                      fixed += 1
                    end
                    TaxonNameRelationship.where(project_id: project_id, object_taxon_name_id: s.id).select{|i| i.type !~ /Combination/}.each do |z|
                      z.object_taxon_name_id = o.id
                      z.save
                      fixed += 1
                    end
                  end
                elsif s.cached_valid_taxon_name_id != svalid
                  TaxonNameRelationship.create(subject_taxon_name: s, object_taxon_name: o, type: 'TaxonNameRelationship::Iczn::Invalidating', created_at: created_at, updated_at: updated_at, created_by_id: created_by_id, updated_by_id: updated_by_id, project_id: project_id)
                else
                  fixed += 1
                end
              end
            end
          end
        end

        def soft_validations_sf(project_id)
          fixed = 0
          print "\nApply soft validation fixes to taxa 1st pass \n"
          i = 0
          GC.start
          TaxonName.where(project_id: project_id).find_each do |t|
            i += 1
            print "\r#{i}    Fixes applied: #{fixed}"
#          next if i < 7346
#          byebug
            t.soft_validate(:all, true, true)
            t.fix_soft_validations
            t.soft_validations.soft_validations.each do |f|
              fixed += 1  if f.fixed?
            end
          end

          print "\nApply soft validation fixes to relationships \n"
          i = 0
          GC.start
          TaxonNameRelationship.where(project_id: project_id).find_each do |t|
            i += 1
            print "\r#{i}    Fixes applied: #{fixed}"
            t.soft_validate(:all, true, true)
            t.fix_soft_validations
            t.soft_validations.soft_validations.each do |f|
              fixed += 1  if f.fixed?
            end
          end
          print "\nApply soft validation fixes to taxa 2nd pass \n"

          i = 0
          GC.start
          TaxonName.where(project_id: project_id).find_each do |t|
            i += 1
            print "\r#{i}    Fixes applied: #{fixed}"
            t.soft_validate(:all, true, true)
            t.fix_soft_validations
            t.soft_validations.soft_validations.each do |f|
              fixed += 1  if f.fixed?
            end
          end
        end

      end
    end
  end
end


