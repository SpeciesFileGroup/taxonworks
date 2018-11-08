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
          # get_tw_project_id = get('SFFileIDToTWProjectID')
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

            # otu_id = get_tw_otu_id[sf_taxon_name_id]
            project_id = otu.project_id.to_s

            logger.info "Working with TW.project_id: #{project_id}, SF.TaxonNameID #{sf_taxon_name_id} = TW.otu_id #{otu.id},
SF.RefID #{sf_ref_id} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']} (count #{count_found += 1}) \n"

            cite_pages = row['CitePages']

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
                    pages: cite_pages,
                    # is_original: (row['SeqNum'] == '1' ? true : false),
                    citation_object: otu, # this one line replaces the next two lines
                    # citation_object_type: 'Otu',
                    # citation_object_id: otu_id,

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
                  citation.pages = "#{cite_pages} [dupl #{row['SeqNum']}"
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
            # logger.info "Citation (= #{old_citation.id}) to this OTU (= #{otu.id}, SF.TaxonNameID #{sf_taxon_name_id}) from this source (= #{source_id}, SF.RefID #{sf_ref_id}) with these pages (= #{cite_pages}) already exists (cite_found_counter = #{cite_found_counter += 1})"
            # old_citation.notes << Note.new(text: "Duplicate citation source to same OTU; nomenclator string = '#{get_nomenclator_string[row['NomenclatorID']]}'", project_id: project_id)
            # # note_text = row['Note'].gsub('|', ':')
            # old_citation.notes << Note.new(text: "Note for duplicate citation = '#{row['Note']}'", project_id: project_id) unless row['Note'].blank?


            ### After citation updated or created

            ## Nomenclator: DataAttribute of citation, NomenclatorID > 0
            if row['NomenclatorID'] != '0' # OR could value: be evaluated below based on NomenclatorID?

              #   
              # TODO: @mbeckman you can no longer create data attributes on Citations, but you can cite data attributes now. This metadata will have to be changed.
              #
              da = DataAttribute.create!(type: 'ImportAttribute',
                                         attribute_subject: citation, # replaces next two lines
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

        # Prior to running next task:
        #   Which dump file to restore
        desc 'time rake tw:project_import:sf_import:citations:create_citations user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define create_citations: [:data_directory, :environment, :user_id] do |logger|

          logger.info 'Creating citations...'

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          skipped_file_ids = import.get('SkippedFileIDs')
          excluded_taxa = import.get('ExcludedTaxa')
          get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping
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
          # get_sf_file_id = import.get('SFTaxonNameIDToSFFileID')

          otu_not_found_array = []

          path = @args[:data_directory] + 'sfCites.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

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

          base_uri = 'http://speciesfile.org/legacy/'

          # @todo commented out 9 July
          # # For each citation row, we must do something, this is the list of those somethings
          # decisions = [
          #
          # ]
          #
          # # Each decision has an outcome, which involves calling one or more methods.
          # # Everything that must be done for the citation row in question must be done
          # # through one of these methods
          # decision_methods = {
          #
          # }

          file.each_with_index do |row, i|
            sf_taxon_name_id = row['TaxonNameID']
            next if excluded_taxa.include? sf_taxon_name_id
            sf_file_id = row['FileID'] # get_sf_file_id[sf_taxon_name_id]   @todo: There is no FileID
            # Hence, skipped_file_ids does not work. However, since taxon_name_id will be nil
            # because it won't be included in the hash, this still works. But ugly!
            next if skipped_file_ids.include? sf_file_id.to_i
            taxon_name_id = get_tw_taxon_name_id[sf_taxon_name_id] # cannot to_i because if nil, nil.to_i = 0

            if taxon_name_id.nil?
              if get_tw_otu_id[sf_taxon_name_id]
                logger.info "SF.TaxonNameID = #{sf_taxon_name_id} previously created as OTU (otu_only_counter = #{otu_only_counter += 1})"
              elsif otu_not_found_array.include? sf_taxon_name_id # already in array (probably seqnum > 1)
                logger.info "SF.TaxonNameID = #{sf_taxon_name_id} already in otu_not_found_array (total in otu_not_found_counter = #{otu_not_found_counter})"
              else
                otu_not_found_array << sf_taxon_name_id # add SF.TaxonNameID to otu_not_found_array
                logger.info "SF.TaxonNameID = #{sf_taxon_name_id} added to otu_not_found_array (otu_not_found_counter = #{otu_not_found_counter += 1})"
              end
              next
            end

            sf_ref_id = row['RefID']
            source_id = get_tw_source_id[sf_ref_id].to_i
            next if source_id == 0

            protonym = TaxonName.find(taxon_name_id)
            project_id = protonym.project_id.to_s #  TaxonName.find(taxon_name_id).project_id.to_s # forced to string for hash value
            nomenclator_string = nil

            # test nomenclator info
            nomenclator_id = row['NomenclatorID']
            if nomenclator_id != '0'
              nomenclator_string = get_nomenclator_metadata[nomenclator_id]['nomenclator_string'].gsub('.  ', '. ') # delete 2nd space after period in var, form, etc.
              nomenclator_ident_qualifier = get_nomenclator_metadata[nomenclator_id]['ident_qualifier']
              # sf_file_id = get_nomenclator_metadata[nomenclator_id]['file_id']
              if nomenclator_ident_qualifier.present? # has some irrelevant text in it
                # logger.warn "No citation created because IdentQualifier has irrelevant data: (SF.FileID: #{sf_file_id}, SF.TaxonNameID: #{sf_taxon_name_id}, SF.RefID #{sf_ref_id} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']})"
                # create data attr on taxon_name

                Note.create!(
                    note_object_type: protonym,
                    note_object_id: taxon_name_id,
                    text: "Citation to '#{get_sf_verbatim_ref[sf_ref_id]}' not created because accompanying nomenclator ('#{nomenclator_string}') contains irrelevant data ('#{nomenclator_ident_qualifier}')",
                    project_id: project_id,
                    created_at: row['CreatedOn'], # housekeeping data from citation not created
                    updated_at: row['LastUpdate'],
                    created_by_id: get_tw_user_id[row['CreatedBy']],
                    updated_by_id: get_tw_user_id[row['ModifiedBy']]
                )
                next
              end
            end

            logger.info "Working with TW.project_id: #{project_id}, SF.TaxonNameID #{sf_taxon_name_id} = TW.taxon_name_id #{taxon_name_id},
SF.RefID #{sf_ref_id} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']} (count #{count_found += 1}) \n"

            cite_pages = row['CitePages']

            new_name_uri = (base_uri + 'new_name_status/' + row['NewNameStatusID']) unless row['NewNameStatusID'] == '0'
            type_info_uri = (base_uri + 'type_info/' + row['TypeInfoID']) unless row['TypeInfoID'] == '0'
            info_flag_status_uri = (base_uri + 'info_flag_status/' + row['InfoFlagStatus']) unless row['InfoFlagStatus'] == '0'

            new_name_cvt_id = get_cvt_id[project_id][new_name_uri]
            type_info_cvt_id = get_cvt_id[project_id][type_info_uri]
            info_flag_status_cvt_id = get_cvt_id[project_id][info_flag_status_uri]

            # ap "NewNameStatusID = #{new_name_cvt_id.to_s}; TypeInfoID = #{type_info_cvt_id.to_s}" # if new_name_cvt_id

            metadata = {
                ## Note: Add as attribute before save citation
                notes_attributes: [{text: row['Note'], # (row['Note'].blank? ? nil :   rejected automatically by notable
                                    project_id: project_id,
                                    created_at: row['CreatedOn'],
                                    updated_at: row['LastUpdate'],
                                    created_by_id: get_tw_user_id[row['CreatedBy']],
                                    updated_by_id: get_tw_user_id[row['ModifiedBy']]}],


                tags_attributes: [{keyword_id: new_name_cvt_id, project_id: project_id}, {keyword_id: type_info_cvt_id, project_id: project_id}],

                ## InfoFlagStatus: Add confidence, 1 = partial data or needs review, 2 = complete data
                confidences_attributes: [{confidence_level_id: info_flag_status_cvt_id, project_id: project_id}]
            }

            is_original = false

            # Original description citation most likely already exists but pages are source pages, not cite pages
            citation = Citation.where(source_id: source_id, citation_object_type: 'TaxonName', citation_object_id: taxon_name_id, is_original: true).first
            if citation != nil and orig_desc_source_id != source_id
              orig_desc_source_id = source_id # prevents duplicate citation to same source being processed as original description
              citation.notes << Note.new(text: row['Note'], project_id: project_id) unless row['Note'].blank?
              citation.update(metadata.merge(pages: cite_pages))

              is_original = true
              # logger.info "Citation found: citation.id = #{citation.id}, taxon_name_id = #{taxon_name_id}, cite_pages = '#{cite_pages}' (cite_found_counter = #{cite_found_counter += 1})"

              if get_containing_source_id[source_id.to_s] # create taxon_name_author role for contained Refs only
                get_sf_taxon_name_authors[sf_ref_id].each do |sf_person_id| # person_id from author_array
                  role = Role.create!(
                      person_id: get_tw_person_id[sf_person_id],
                      type: 'TaxonNameAuthor',
                      role_object_id: taxon_name_id,
                      role_object_type: 'TaxonName',
                      project_id: project_id, # role is project_role
                      )
                end
              end
            end

            if !nomenclator_string.blank? && !nomenclator_string.include?('?') # has ? in string, skip combo but record string as tag
              if !nomenclator_is_original_combination?(protonym, nomenclator_string) && !nomenclator_is_current_name?(protonym, nomenclator_string)
                combination = nil

                # @todo commented out 9 July
                # # [INFO]2018-03-21 04:23:59.785: total funny exceptions = '13410', total unique_bad_nomenclators = '4933'
                # # [INFO]2018-03-30 03:43:54.967: total funny exceptions = '56295', total unique_bad_nomenclators = '23051', new combo total = 14097
                # # [INFO]2018-03-31 18:44:23.471: total funny exceptions = '35106', total unique_bad_nomenclators = '15822', new combo total = 21,275
                # cr = TaxonWorks::Vendor::Biodiversity::Result.new(query_string: nomenclator_string, project_id: project_id, code: :iczn)
                #
                # kn = {
                #     project_id: project_id,
                #     nomenclator_string: nomenclator_string,
                #     cr: cr,
                #     protonym: protonym,
                #
                #     housekeeping: {
                #         project_id: project_id,
                #         created_at: row['CreatedOn'],
                #         updated_at: row['LastUpdate'],
                #         created_by_id: get_tw_user_id[row['CreatedBy']],
                #         updated_by_id: get_tw_user_id[row['ModifiedBy']]
                #     }
                # }
                #
                # kn[:is_original_combination] = true if is_original
                #
                # done = false
                #
                # [:m_single_match, :m_unambiguous, :m_current_species_homonym].each do |m|
                #   passed, c = send(m, kn) # return passed & c (= combination); args to m (= method), kn (= knowns)
                #   if passed
                #     if c.new_record?
                #       c.by = 1
                #       c.project_id = project_id
                #       c.save!
                #       new_combination_counter += 1
                #     end
                #     done = true
                #     taxon_name_id = c.id
                #     # total_combination_counter += 1
                #   end
                #   break if done
                # end
                #
                # if done
                #   logger.info Rainbow("Successful combination: new_combination_counter = #{new_combination_counter}, total_combination_counter = #{total_combination_counter}").rebeccapurple.bold
                # else # unsuccessful
                #   funny_exceptions_counter += 1
                #   unique_bad_nomenclators[nomenclator_string] = project_id
                #
                #   logger.warn "Funny exceptions ELSE nomenclator_string = '#{nomenclator_string}', cr.detail = '#{cr.detail}', cr.ambiguous_ranks = '#{cr.ambiguous_ranks}' (unique_bad_nomenclators.count = #{unique_bad_nomenclators.count})"
                # end
              end
            end

            if !is_original
              citation = Citation.new(
                  metadata.merge(
                      source_id: source_id,
                      pages: cite_pages,
                      is_original: (row['SeqNum'] == '1' ? true : false),
                      citation_object_type: 'TaxonName',
                      citation_object_id: taxon_name_id,

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
                  logger.error "Citation ERROR [TW.project_id: #{project_id}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{protonym.id},
SF.RefID #{sf_ref_id} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']}] (#{error_counter += 1}): " + citation.errors.full_messages.join(';')
                  next
                else # make pages unique and save again
                  if citation.errors.messages[:source_id].include?('has already been taken') # citation.errors.messages[:source_id][0] == 'has already been taken'
                    citation.pages = "#{cite_pages} [dupl #{row['SeqNum']}"
                    begin
                      citation.save!
                    rescue ActiveRecord::RecordInvalid
                      # [ERROR]2018-03-30 17:09:43.127: Citation ERROR [TW.project_id: 11, SF.TaxonNameID 1152999 = TW.taxon_name_id 47338, SF.RefID 16047 = TW.source_id 12047, SF.SeqNum 2, nomenclator_string = Limnoperla jaffueli, name_status = 3] (total_error_counter = 1, source_used_counter = 1): Source has already been taken
                      logger.error "Citation ERROR [TW.project_id: #{project_id}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{protonym.id}, SF.RefID #{sf_ref_id} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']}, nomenclator_string = #{nomenclator_string}, name_status = #{row['NewNameStatusID']}], (current_error_counter = #{error_counter += 1}, source_used_counter = #{source_used_counter += 1}): " + citation.errors.full_messages.join(';')
                      logger.info "NewNameStatusID = #{row['NewNameStatusID']}, count = #{new_name_status[row['NewNameStatusID'].to_i] += 1}"
                      next
                    end
                  else # citation error was not already been taken (other validation failure)
                    logger.error "Citation ERROR [TW.project_id: #{project_id}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{protonym.id}, SF.RefID #{sf_ref_id} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']}] (#{error_counter += 1}): " + citation.errors.full_messages.join(';')
                    next
                  end
                end
              end
            end

            ### After citation updated or created
            ## Nomenclator: DataAttribute of citation, NomenclatorID > 0

            if nomenclator_string # OR could value: be evaluated below based on NomenclatorID?
              da = DataAttribute.new(type: 'ImportAttribute',
                                     # attribute_subject_id: citation.id,
                                     # attribute_subject_type: 'Citation',
                                     attribute_subject: citation, # replaces two lines above
                                     import_predicate: 'Nomenclator',
                                     value: "#{nomenclator_string} (TW.project_id: #{project_id}, SF.TaxonNameID #{sf_taxon_name_id} = TW.taxon_name_id #{taxon_name_id}, SF.RefID #{sf_ref_id} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']})",
                                     project_id: project_id,
                                     created_at: row['CreatedOn'],
                                     updated_at: row['LastUpdate'],
                                     created_by_id: get_tw_user_id[row['CreatedBy']],
                                     updated_by_id: get_tw_user_id[row['ModifiedBy']]
              )
              begin
                da.save!
                  # puts 'DataAttribute Nomenclator created'
              rescue ActiveRecord::RecordInvalid # da not valid
                logger.error "DataAttribute Nomenclator ERROR NomenclatorID = #{row['NomenclatorID']}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{taxon_name_id} (error_counter = #{error_counter += 1}): " + da.errors.full_messages.join(';')
              end
            end

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
                pages: cite_pages,
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

          # logger.info "total funny exceptions = '#{funny_exceptions_counter}', total unique_bad_nomenclators = '#{unique_bad_nomenclators.count}', \n unique_bad_nomenclators = '#{unique_bad_nomenclators}'"
          # ap "total funny exceptions = '#{funny_exceptions_counter}', total unique_bad_nomenclators = '#{unique_bad_nomenclators.count}', \n unique_bad_nomenclators = '#{unique_bad_nomenclators}'"
          puts 'new_name_status hash:'
          ap new_name_status
        end

      end
    end
  end
end


