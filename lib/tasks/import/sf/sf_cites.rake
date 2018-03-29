namespace :tw do
  namespace :project_import do
    namespace :sf_import do
      require 'fileutils'
      require 'logged_task'
      namespace :cites do

        desc 'time rake tw:project_import:sf_import:cites:create_otu_cites user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define create_otu_cites: [:data_directory, :environment, :user_id] do |logger|

          logger.info 'Creating citations for OTUs...'

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping
          # get_tw_project_id = get('SFFileIDToTWProjectID')
          # get_tw_taxon_name_id = import.get('SFTaxonNameIDToTWTaxonNameID')
          get_tw_otu_id = import.get('SFTaxonNameIDToTWOtuID') # Note this is an OTU associated with a SF.TaxonNameID (probably a bad taxon name)
          # get_taxon_name_otu_id = import.get('TWTaxonNameIDToOtuID') # Note this is the OTU offically associated with a real TW.taxon_name_id
          get_tw_source_id = import.get('SFRefIDToTWSourceID')
          get_nomenclator_string = import.get('SFNomenclatorIDToSFNomenclatorString')
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
                #     #  {keyword_id: (row['NewNameStatus'].to_i > 0 ? ControlledVocabularyTerm.where('uri LIKE ? and project_id = ?', "%/new_name_status/#{row['NewNameStatusID']}", project_id).limit(1).pluck(:id).first : nil), project_id: project_id},
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
                logger.info "Citation ERROR [TW.project_id: #{project_id}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{taxon_name_id},
SF.RefID #{sf_ref_id} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']}] (#{error_counter += 1}): " + citation.errors.full_messages.join(';')
                next
              else # make pages unique and save again
                if citation.errors.messages[:source_id].include?('has already been taken') # citation.errors.messages[:source_id][0] == 'has already been taken'
                  citation.pages = "#{cite_pages} [dupl #{row['SeqNum']}"
                  begin
                    citation.save!
                  rescue ActiveRecord::RecordInvalid
                    logger.info "Citation ERROR [TW.project_id: #{project_id}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{taxon_name_id}, SF.RefID #{sf_ref_id} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']}] (#{error_counter += 1}): " + citation.errors.full_messages.join(';')
                    next
                  end
                else # citation error was not already been taken (other validation failure)
                  logger.info "Citation ERROR [TW.project_id: #{project_id}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{taxon_name_id}, SF.RefID #{sf_ref_id} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']}] (#{error_counter += 1}): " + citation.errors.full_messages.join(';')
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
              da = DataAttribute.create!(type: 'ImportAttribute',
                                         attribute_subject: citation, # replaces next two lines
                                         # attribute_subject_id: citation.id,
                                         # attribute_subject_type: 'Citation',
                                         import_predicate: 'Nomenclator',
                                         value: get_nomenclator_string[row['NomenclatorID']],
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

        def m_single_match(knowns) # test for single match
          potential_matches = TaxonName.where(cached: knowns[:nomenclator_string], project_id: knowns[:project_id])
          if potential_matches.count == 1
            return true, potential_matches.first
          end
          return false, nil
        end

        def m_unambiguous(knowns) # test combination is unambiguous and has genus
          if knowns[:check_result].is_unambiguous?
            if knowns[:check_result].genus
              return true, knowns[:check_result].combination
            end
          end
          return false, nil
        end

        def m_current_species_homonym(knowns) # test known genus and current species homonym
          if knowns[:protonym_rank] == "species" && knowns[:check_result].disambiguated_combination(species: knowns[:protonym]).get_full_name == knowns[:nomenclator_string]
            return true, knowns[:check_result].disambiguated_combination(species: knowns[:protonym])
          end
          return false, nil
        end


        desc 'time rake tw:project_import:sf_import:cites:create_citations user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define create_citations: [:data_directory, :environment, :user_id] do |logger|

          logger.info 'Creating list of taxa with AccessCode = 4'
          taxa_access_code_4 = [1143399, 1143399, 1143402, 1143402, 1143403, 1143403, 1143403, 1143404, 1143405, 1143406, 1143408, 1143414, 1143415, 1143416, 1143417, 1143418, 1143419, 1143420, 1143421, 1143422, 1143423, 1143425, 1143430, 1143431, 1143434, 1143435, 1143436, 1143437, 1143438, 1207769, 1232866]


          logger.info 'Creating citations...'

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          skipped_file_ids = import.get('SkippedFileIDs')
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
          successful_combination_counter = 0

          unique_bad_nomenclators = {}

          base_uri = 'http://speciesfile.org/legacy/'

          file.each_with_index do |row, i|
            next if taxa_access_code_4.include? row['TaxonNameID'].to_i
            sf_taxon_name_id = row['TaxonNameID']
            sf_file_id = row['FileID'] # get_sf_file_id[sf_taxon_name_id]
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
                logger.warn "No citation created because IdentQualifier has irrelevant data: (SF.FileID: #{sf_file_id}, SF.TaxonNameID: #{sf_taxon_name_id}, SF.RefID #{sf_ref_id} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']})"
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

            logger.info "Working with TW.project_id: #{project_id}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{taxon_name_id},
SF.RefID #{sf_ref_id} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']} (count #{count_found += 1}) \n"

            cite_pages = row['CitePages']

            new_name_uri = (base_uri + 'new_name_status/' + row['NewNameStatusID']) unless row['NewNameStatusID'] == '0'
            type_info_uri = (base_uri + 'type_info/' + row['TypeInfoID']) unless row['TypeInfoID'] == '0'
            info_flag_status_uri = (base_uri + 'info_flag_status/' + row['InfoFlagStatus']) unless row['InfoFlagStatus'] == '0'

            new_name_cvt_id = get_cvt_id[project_id][new_name_uri] #   Keyword.where('uri = ? AND project_id = ?', new_name_uri, project_id).limit(1).pluck(:id).first if new_name_uri
            type_info_cvt_id = get_cvt_id[project_id][type_info_uri] #  Keyword.where('uri = ? AND project_id = ?', type_info_uri, project_id).limit(1).pluck(:id).first if type_info_uri
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

                ## NewNameStatus: As tags to citations, create 16 keywords for each project, set up in case statement; test for NewNameStatusID > 0
                ## TypeInfo: As tags to citations, create n keywords for each project, set up in case statement (2364 cases!)
                # tags_attributes: [
                #     #  {keyword_id: (row['NewNameStatus'].to_i > 0 ? ControlledVocabularyTerm.where('uri LIKE ? and project_id = ?', "%/new_name_status/#{row['NewNameStatusID']}", project_id).limit(1).pluck(:id).first : nil), project_id: project_id},
                #     #  {keyword_id: (row['TypeInfoID'].to_i > 0 ? ControlledVocabularyTerm.where('uri LIKE ? and project_id = ?', "%/type_info/#{row['TypeInfoID']}", project_id).limit(1).pluck(:id).first : nil), project_id: project_id}
                #     {keyword_id: (new_name_uri ? new_name_cvt_id : nil), project_id: project_id},
                #     {keyword_id: (type_info_uri ? Keyword.where('uri = ? AND project_id = ?', type_info_uri, project_id).limit(1).pluck(:id).first : nil), project_id: project_id}
                #
                # ],

                tags_attributes: [{keyword_id: new_name_cvt_id, project_id: project_id}, {keyword_id: type_info_cvt_id, project_id: project_id}],

                ## InfoFlagStatus: Add confidence, 1 = partial data or needs review, 2 = complete data
                confidences_attributes: [{confidence_level_id: info_flag_status_cvt_id, project_id: project_id}]
            }

            # Original description citation most likely already exists but pages are source pages, not cite pages
            citation = Citation.where(source_id: source_id, citation_object_type: 'TaxonName', citation_object_id: taxon_name_id, is_original: true).first
            if citation != nil and orig_desc_source_id != source_id
              orig_desc_source_id = source_id # prevents duplicate citation to same source being processed as original description
              citation.notes << Note.new(text: row['Note'], project_id: project_id) unless row['Note'].blank?
              # citation.update_column(:pages, cite_pages) # update pages to cite_pages
              citation.update(metadata.merge(pages: cite_pages))
              logger.info "Citation found: citation.id = #{citation.id}, taxon_name_id = #{taxon_name_id}, cite_pages = '#{cite_pages}' (cite_found_counter = #{cite_found_counter += 1})"

              if get_containing_source_id[source_id.to_s] # create taxon_name_author role for contained Refs only

                # byebug

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


            else # create new citation
              # byebug

              if nomenclator_string
                if !nomenclator_is_original_combination?(protonym, nomenclator_string) && !nomenclator_is_current_name?(protonym, nomenclator_string)

                  combination = nil

                  # begin # multiple matches, need to parse
                  # [INFO]2018-03-21 04:23:59.785: total funny exceptions = '13410', total unique_bad_nomenclators = '4933'
                  check_result = TaxonWorks::Vendor::Biodiversity::Result.new(query_string: nomenclator_string, project_id: project_id, code: :iczn)

                  knowns = {
                      project_id: project_id,
                      nomenclator_string: nomenclator_string,
                      check_result: check_result,
                      protonym: protonym,
                      protonym_id: protonym.id,
                      protonym_rank: protonym.rank,
                      protonym_parent_id: protonym.parent_id,
                      protonym_orig_comb: protonym.cached_original_combination,
                      prononym_full_name: protonym.get_full_name
                  }
                  done = false

                  [:m_single_match, :m_unambiguous, :m_current_species_homonym].each do |m|
                    passed, c = send(m, knowns) # return passed & c (= combination); args to m (= method), knowns
                    if passed
                      if c.new_record?
                        c.by = 1
                        c.project_id = project_id
                        c.save!
                      end
                      taxon_name_id = c.id
                      done = true
                    end
                    break if done
                  end


                  # other test cases:
                  # test is_subspecies and species.name = subspecies.name
                  # test is_subspecies and different rank names
                  # test has subgenus (and above test cases)
                  # test genus homonyms (other_matches?)
                  #
                  # difficult cases:
                  # misspelling of current taxon w/o synonym


                else
                  # ... this is all the funny exceptions (4)

                  funny_exceptions_counter += 1
                  unique_bad_nomenclators[nomenclator_string] = project_id

                  logger.warn "Funny exceptions ELSE nomenclator_string = '#{nomenclator_string}', check_result.detail = '#{check_result.detail}', check_result.ambiguous_ranks = '#{check_result.ambiguous_ranks}' (unique_bad_nomenclators.count = #{unique_bad_nomenclators.count})"

                  logger.warn "Unaccounted for species errors"
                end


=begin

documentation block only

cr.disambiguated_combo genus: value, species: value, etc.
cr.combination => 
cr.ambiguous_ranks
cr.protonyms(:genus) returns genus obj incl id => genus_id = cr.protonyms(:genus).pluck(:id)
cr.finest_rank => :species
cr.species => "reticulata"
current_cite_id = [from cite record]
current_cite_object = Protonym.find(current_cite_id)
current_cite_object_name = Protonym.find(current_cite_id).name
cr_name = cr.species => "reticulata"

has_genus = cr.detail.has_key?(:genus)

find all ranks in nomenclator_string
find where unambiguous (get protonym_ids for those)
find out if current cite name matches ambiguous finest, match them up

priority of steps
accumulate all given IDs that we know (genus, species subgenus)
have current name's ID, rank, parent_id, parent_rank,
get parent ID and orig genus ID (if species)
(acts_as_list gem with hierarchical methods)

other_matches
c2.get_full_name == nomenclator_string

cr nomen_str
c2 = cr.disambiguated_combination(species: current_name_id)
c2.get_full_name == nomenclator_string (must check)
 c2.save!
 set taxon_name_id = c2.id

=end

                #     funny_exceptions_counter += 1
                #     unique_bad_nomenclators[nomenclator_string] = project_id
                #
                #     logger.warn "Funny exceptions ELSE nomenclator_string = '#{nomenclator_string}', check_result.detail = '#{check_result.detail}', check_result.ambiguous_ranks = '#{check_result.ambiguous_ranks}' (unique_bad_nomenclators.count = #{unique_bad_nomenclators.count})"
                #   end
                # end

                # Put all the rescue statements in one place
                #     rescue ActiveRecord::RecordInvalid
                #       logger.error "Combination ERROR [TW.project_id: #{project_id}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{protonym.id}, SF.RefID #{sf_ref_id} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']}] (#{error_counter += 1}): " + combination.errors.full_messages.join(';')
                #     rescue TypeError
                #       # message about type / problems with   TaxonWorks::Vendor::Biodiversity::Result
                #       logger.error "Bad nomenclator string? nomen str = #{nomenclator_string}"
                #     rescue
                #       raise
                #     end
                #   end
                # end
              end # block that does stuff if nomenclator_string exists

              # combination check
              # synonym or taxon_name_relationship check

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
                  logger.info "Citation ERROR [TW.project_id: #{project_id}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{protonym.id},
SF.RefID #{sf_ref_id} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']}] (#{error_counter += 1}): " + citation.errors.full_messages.join(';')
                  next
                else # make pages unique and save again
                  if citation.errors.messages[:source_id].include?('has already been taken') # citation.errors.messages[:source_id][0] == 'has already been taken'
                    citation.pages = "#{cite_pages} [dupl #{row['SeqNum']}"
                    begin
                      citation.save!
                    rescue ActiveRecord::RecordInvalid
                      logger.info "Citation ERROR [TW.project_id: #{project_id}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{protonym.id}, SF.RefID #{sf_ref_id} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']}] (#{error_counter += 1}): " + citation.errors.full_messages.join(';')
                      next
                    end
                  else # citation error was not already been taken (other validation failure)
                    logger.info "Citation ERROR [TW.project_id: #{project_id}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{protonym.id}, SF.RefID #{sf_ref_id} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']}] (#{error_counter += 1}): " + citation.errors.full_messages.join(';')
                    next
                  end
                end
              end
            end

            ### After citation updated or created

            ## Nomenclator: DataAttribute of citation, NomenclatorID > 0
            if nomenclator_string # OR could value: be evaluated below based on NomenclatorID?
              da = DataAttribute.new(type: 'ImportAttribute',
                                     attribute_subject_id: citation.id,
                                     attribute_subject_type: 'Citation',
                                     # attribute_subject: citation,        replaces two lines above
                                     import_predicate: 'Nomenclator',
                                     value: nomenclator_string,
                                     project_id: project_id,
                                     created_at: row['CreatedOn'],
                                     updated_at: row['LastUpdate'],
                                     created_by_id: get_tw_user_id[row['CreatedBy']],
                                     updated_by_id: get_tw_user_id[row['ModifiedBy']]
              )
              begin
                da.save!
                puts 'DataAttribute Nomenclator created'
              rescue ActiveRecord::RecordInvalid # da not valid
                logger.error "DataAttribute Nomenclator ERROR NomenclatorID = #{row['NomenclatorID']}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{taxon_name_id} (error_counter = #{error_counter += 1}): " + da.errors.full_messages.join(';')
              end
            end


            ## ConceptChange: For now, do not import, only 2000 out of 31K were not automatically calculated, downstream in TW we will use Euler


            ## CurrentConcept: bit: For now, do not import
            # select * from tblCites c inner join tblTaxa t on c.TaxonNameID = t.TaxonNameID where c.CurrentConcept = 1 and t.NameStatus = 7


            ## InfoFlags: Attribute/topic of citation?!! Treat like StatusFlags for individual values
            # Use as topics on citations for OTUs, make duplicate citation on OTU, then topic on that citation
            # inner loop on each citation to iterate through multiple topics contained in bitwise InfoFlags

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

          logger.info "total funny exceptions = '#{funny_exceptions_counter}', total unique_bad_nomenclators = '#{unique_bad_nomenclators.count}', \n unique_bad_nomenclators = '#{unique_bad_nomenclators}'"
        end

        desc 'time rake tw:project_import:sf_import:cites:check_original_genus_ids user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define check_original_genus_ids: [:data_directory, :environment, :user_id] do |logger|
          # Though TW species groups, etc. have an original genus, SF ones do not: Do not infer it at this time

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          skipped_file_ids = import.get('SkippedFileIDs')
          get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping
          get_tw_project_id = import.get('SFFileIDToTWProjectID')
          get_tw_taxon_name_id = import.get('SFTaxonNameIDToTWTaxonNameID') # key = SF.TaxonNameID, value = TW.taxon_name.id

          count_found = 0

          path = @args[:data_directory] + 'sfTaxaByTaxonNameStr.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each_with_index do |row, i|
            taxon_name_id = row['TaxonNameID']
            next if skipped_file_ids.include? row['FileID'].to_i
            next unless taxon_name_id.to_i > 0
            next unless row['RankID'].to_i < 11 # only look at species and subspecies
            next if row['OriginalGenusID'] == '0'
            next if row['TaxonNameStr'].start_with?('1100048-1143863') # name = MiscImages (body parts)
            next if row['AccessCode'].to_i == 4

            species_id = get_tw_taxon_name_id[taxon_name_id]
            next unless species_id

            original_genus_id = get_tw_taxon_name_id[row['OriginalGenusID']] # if error?

            species_protonym = Protonym.find(species_id)
            if species_protonym.original_genus.nil?
              # species_protonym.update(original_genus: )
              logger.info "Working with SF.TaxonNameID #{taxon_name_id} = TW.taxon_name_id (count #{count_found += 1}) \n"
              TaxonNameRelationship::OriginalCombination::OriginalGenus.create!(
                  subject_taxon_name_id: original_genus_id,
                  object_taxon_name_id: species_id,
                  created_by_id: get_tw_user_id[row['CreatedBy']],
                  updated_by_id: get_tw_user_id[row['CreatedBy']],
                  project_id: get_tw_project_id[row['FileID']])
            end
          end
        end


        desc 'time rake tw:project_import:sf_import:cites:create_sf_taxon_file_id_hash user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define create_sf_taxon_file_id_hash: [:data_directory, :environment, :user_id] do |logger|

          logger.info 'Running create_sf_taxon_file_id_hash...'

          get_sf_file_id = {} # key = SF.TaxonNameID, value = SF.FileID

          path = @args[:data_directory] + 'sfTaxonNameIDFileIDs.txt'
          file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each_with_index do |row, i|

            logger.info "Working with SF.TaxonNameID = '#{row['TaxonNameID']}', SF.FileID = '#{row['FileID']}' \n"

            get_sf_file_id[row['TaxonNameID']] = row['FileID']
          end

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          import.set('SFTaxonNameIDToSFFileID', get_sf_file_id)

          puts 'SFTaxonNameIDToSFFileID'
          ap get_sf_file_id
        end

# def create_otu_cite(logger, row, otu_id)
#   # citation, notes, NameStatus, StatusFlags, OriginalGenusID, Distribution, Ecology, CurrentConceptID, NecAuthor, dataflags, extinct, fileID
#
# end

        desc 'time rake tw:project_import:sf_import:cites:create_sf_taxon_name_authors user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define create_sf_taxon_name_authors: [:data_directory, :environment, :user_id] do |logger|

          logger.info 'Running create_sf_taxon_name_authors...'

          get_sf_taxon_name_authors = {} # key = SF.RefID (contained ref), value = array of SF.Person.IDs (ordered)

          path = @args[:data_directory] + 'sfRefsPeople.txt'
          file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          counter = 0
          previous_ref_id = ''

          file.each_with_index do |row, i|
            ref_id = row['RefID']

            logger.info "working with (contained) RefID #{ref_id} (counter #{counter += 1})"

            if ref_id == previous_ref_id # this is the same RefID as last row, add another author
              get_sf_taxon_name_authors[ref_id].push(row['PersonID'])

            else # this is a new RefID, start a new author array
              get_sf_taxon_name_authors[ref_id] = [row['PersonID']]
              previous_ref_id = ref_id
            end
          end

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          import.set('SFRefIDToTaxonNameAuthors', get_sf_taxon_name_authors)

          puts 'SFRefIDToTaxonNameAuthors'
          ap get_sf_taxon_name_authors
        end

        desc 'time rake tw:project_import:sf_import:cites:create_cvts_for_citations user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
# @todo Do I really need a data_directory if I'm using a Postgres table? Not that it hurts...
        LoggedTask.define create_cvts_for_citations: [:data_directory, :environment, :user_id] do |logger|

          # Create controlled vocabulary terms (CVTS) for NewNameStatus, TypeInfo, and CiteInfoFlags; CITES_CVTS below in all caps denotes constant

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          get_tw_project_id = import.get('SFFileIDToTWProjectID')

          CITES_CVTS = {

              new_name_status: [
                  {name: 'unchanged', definition: 'Status of name did not change', uri: 'http://speciesfile.org/legacy/new_name_status/1', uri_relation: 'skos:closeMatch', type: 'Keyword'},
                  {name: 'new name', definition: 'New name, unneeded emendation or subsequent mispelling', uri: 'http://speciesfile.org/legacy/new_name_status/2', uri_relation: 'skos:closeMatch', type: 'Keyword'},
                  {name: 'made synonym', definition: 'Status of name changed to synonym', uri: 'http://speciesfile.org/legacy/new_name_status/3', uri_relation: 'skos:closeMatch', type: 'Keyword'},
                  {name: 'made valid or temporary', definition: 'Name treated as valid or temporary', uri: 'http://speciesfile.org/legacy/new_name_status/4', uri_relation: 'skos:closeMatch', type: 'Keyword'},
                  {name: 'new combination', definition: 'Remains valid in new combination', uri: 'http://speciesfile.org/legacy/new_name_status/5', uri_relation: 'skos:closeMatch', type: 'Keyword'},
                  {name: 'new nomen nudum', definition: 'Name is a new nomen nudum', uri: 'http://speciesfile.org/legacy/new_name_status/6', uri_relation: 'skos:closeMatch', type: 'Keyword'},
                  {name: 'nomen dubium', definition: 'Name treated as nomen dubium', uri: 'http://speciesfile.org/legacy/new_name_status/7', uri_relation: 'skos:closeMatch', type: 'Keyword'},
                  {name: 'missed previous change', definition: 'Apparently missed a previous change', uri: 'http://speciesfile.org/legacy/new_name_status/8', uri_relation: 'skos:closeMatch', type: 'Keyword'},
                  {name: 'still synonym, but of different taxon', definition: 'Name remains a synonym , but of different taxon', uri: 'http://speciesfile.org/legacy/new_name_status/9', uri_relation: 'skos:closeMatch', type: 'Keyword'},
                  {name: 'gender change', definition: 'Name changed to match gender of genus', uri: 'http://speciesfile.org/legacy/new_name_status/10', uri_relation: 'skos:closeMatch', type: 'Keyword'},
                  {name: 'new corrected name', definition: 'Justified emendation, corrected lapsus, or nomen nudum made available', uri: 'http://speciesfile.org/legacy/new_name_status/17', uri_relation: 'skos:closeMatch', type: 'Keyword'},
                  {name: 'different combination', definition: 'Remains valid in restored combination', uri: 'http://speciesfile.org/legacy/new_name_status/18', uri_relation: 'skos:closeMatch', type: 'Keyword'},
                  {name: 'made valid in new combination', definition: 'Made valid in new or different combination', uri: 'http://speciesfile.org/legacy/new_name_status/19', uri_relation: 'skos:closeMatch', type: 'Keyword'},
                  {name: 'incorrect name before correct', definition: 'Nomen nudum, incorrect spelling or lapsus before proper name', uri: 'http://speciesfile.org/legacy/new_name_status/20', uri_relation: 'skos:closeMatch', type: 'Keyword'},
                  {name: 'misapplied name', definition: 'Misapplied name used for misidentified specimen', uri: 'http://speciesfile.org/legacy/new_name_status/22', uri_relation: 'skos:closeMatch', type: 'Keyword'},
              ],

              type_info: [
                  {name: 'unspecified type information', definition: 'tblTypeInfo: unspecified type information', uri: 'http://speciesfile.org/legacy/type_info/1', uri_relation: 'skos:closeMatch', type: 'Keyword'},
                  {name: 'ruling by Commission', definition: 'tblTypeInfo: ruling by Commission', uri: 'http://speciesfile.org/legacy/type_info/2', uri_relation: 'skos:closeMatch', type: 'Keyword'},
                  {name: 'designated syntypes', definition: 'tblTypeInfo: designated syntypes', uri: 'http://speciesfile.org/legacy/type_info/11', uri_relation: 'skos:closeMatch', type: 'Keyword'},
                  {name: 'designated holotype', definition: 'tblTypeInfo: designated holotype', uri: 'http://speciesfile.org/legacy/type_info/12', uri_relation: 'skos:closeMatch', type: 'Keyword'},
                  {name: 'designated lectotype', definition: 'tblTypeInfo: designated lectotype', uri: 'http://speciesfile.org/legacy/type_info/13', uri_relation: 'skos:closeMatch', type: 'Keyword'},
                  {name: 'designated neotype', definition: 'tblTypeInfo: designated neotype', uri: 'http://speciesfile.org/legacy/type_info/14', uri_relation: 'skos:closeMatch', type: 'Keyword'},
                  {name: 'removed syntype(s)', definition: 'tblTypeInfo: removed syntype(s)', uri: 'http://speciesfile.org/legacy/type_info/15', uri_relation: 'skos:closeMatch', type: 'Keyword'},
                  {name: 'original monotypy', definition: 'tblTypeInfo: original monotypy', uri: 'http://speciesfile.org/legacy/type_info/21', uri_relation: 'skos:closeMatch', type: 'Keyword'},
                  {name: 'original designation', definition: 'tblTypeInfo: original designation', uri: 'http://speciesfile.org/legacy/type_info/22', uri_relation: 'skos:closeMatch', type: 'Keyword'},
                  {name: 'subsequent designation', definition: 'tblTypeInfo: subsequent designation', uri: 'http://speciesfile.org/legacy/type_info/23', uri_relation: 'skos:closeMatch', type: 'Keyword'},
                  {name: 'monotypy and original designation', definition: 'tblTypeInfo: monotypy and original designation', uri: 'http://speciesfile.org/legacy/type_info/24', uri_relation: 'skos:closeMatch', type: 'Keyword'},
                  {name: 'removed potential type(s)', definition: 'tblTypeInfo: removed potential type(s)', uri: 'http://speciesfile.org/legacy/type_info/25', uri_relation: 'skos:closeMatch', type: 'Keyword'},
                  {name: 'absolute tautonomy', definition: 'tblTypeInfo: absolute tautonomy', uri: 'http://speciesfile.org/legacy/type_info/26', uri_relation: 'skos:closeMatch', type: 'Keyword'},
                  {name: 'Linnaean tautonomy', definition: 'tblTypeInfo: Linnaean tautonomy', uri: 'http://speciesfile.org/legacy/type_info/27', uri_relation: 'skos:closeMatch', type: 'Keyword'},
                  {name: 'inherited from replaced name', definition: 'tblTypeInfo: inherited from replaced name', uri: 'http://speciesfile.org/legacy/type_info/29', uri_relation: 'skos:closeMatch', type: 'Keyword'},
              ],

              # uri end number represents bit position, not value
              cite_info_flags: [
                  {name: 'Image or description', definition: 'An image or description is included', uri: 'http://speciesfile.org/legacy/cite_info_flags/0', uri_relation: 'skos:closeMatch', type: 'Topic'},
                  {name: 'Phylogeny or classification', definition: 'An evolutionary relationship or hierarchical position is presented or discussed', uri: 'http://speciesfile.org/legacy/cite_info_flags/1', uri_relation: 'skos:closeMatch', type: 'Topic'},
                  {name: 'Ecological data', definition: 'Ecological data are included', uri: 'http://speciesfile.org/legacy/cite_info_flags/2', uri_relation: 'skos:closeMatch', type: 'Topic'},
                  {name: 'Specimen or distribution', definition: 'Specimen or distribution information is included', uri: 'http://speciesfile.org/legacy/cite_info_flags/3', uri_relation: 'skos:closeMatch', type: 'Topic'},
                  {name: 'Key', definition: 'A key for identification is included', uri: 'http://speciesfile.org/legacy/cite_info_flags/4', uri_relation: 'skos:closeMatch', type: 'Topic'},
                  {name: 'Life history', definition: 'Life history information is included', uri: 'http://speciesfile.org/legacy/cite_info_flags/5', uri_relation: 'skos:closeMatch', type: 'Topic'},
                  {name: 'Behavior', definition: 'Behavior information is included', uri: 'http://speciesfile.org/legacy/cite_info_flags/6', uri_relation: 'skos:closeMatch', type: 'Topic'},
                  {name: 'Economic matters', definition: 'Economic matters are included', uri: 'http://speciesfile.org/legacy/cite_info_flags/7', uri_relation: 'skos:closeMatch', type: 'Topic'},
                  {name: 'Physiology', definition: 'Physiology is included', uri: 'http://speciesfile.org/legacy/cite_info_flags/8', uri_relation: 'skos:closeMatch', type: 'Topic'},
                  {name: 'Structure', definition: 'Anatomy, cytology, genetic or other structural information is included', uri: 'http://speciesfile.org/legacy/cite_info_flags/9', uri_relation: 'skos:closeMatch', type: 'Topic'},
              ],

              info_flag_status: [
                  {name: 'partial data or needs review', definition: 'InfoFlagStatus: partial data or needs review', uri: 'http://speciesfile.org/legacy/info_flag_status/1', uri_relation: 'skos:closeMatch', type: 'ConfidenceLevel'},
                  {name: 'complete data', definition: 'InfoFlagStatus: complete data', uri: 'http://speciesfile.org/legacy/info_flag_status/2', uri_relation: 'skos:closeMatch', type: 'ConfidenceLevel'},
              ]

          }.freeze

          logger.info 'Running create_cvts_for_citations...'

          get_cvt_id = {} # key = project_id, value = {tag/topic uri, cvt.id.to_s}

          # Project.all.each do |project|
          get_tw_project_id.each_value do |project_id|
            # next unless project.name.end_with?('species_file')

            # project_id = project.id.to_s

            logger.info "Working with TW.project_id: #{project_id}"

            get_cvt_id[project_id] = {} # initialized for outer loop with project_id

            CITES_CVTS.each_key do |column| # tblCites.ColumnName
              CITES_CVTS[column].each do |params|
                cvt = ControlledVocabularyTerm.create!(params.merge(project_id: project_id)) # want this to be integer
                get_cvt_id[project_id][cvt.uri] = cvt.id.to_s
              end
            end
          end

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          import.set('CvtProjUriID', get_cvt_id)

          puts = 'CvtProjUriID'
          ap get_cvt_id

        end

        desc 'time rake tw:project_import:sf_import:cites:import_nomenclator_metadata user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define import_nomenclator_strings: [:data_directory, :environment, :user_id] do |logger|
          # Can be run independently at any time

          logger.info 'Running import_nomenclator_metadata...'

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          skipped_file_ids = import.get('SkippedFileIDs')

          get_nomenclator_metadata = {} # key = SF.NomenclatorID, value = nomenclator_string, ident_qualifier, file_id

          count_found = 0

          path = @args[:data_directory] + 'sfNomenclatorStrings.txt'
          file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each_with_index do |row, i|
            next if skipped_file_ids.include? row['FileID'].to_i
            nomenclator_id = row['NomenclatorID']
            next if nomenclator_id == '0'

            nomenclator_string = row['NomenclatorString']

            logger.info "Working with SF.NomenclatorID '#{nomenclator_id}', SF.NomenclatorString '#{nomenclator_string}' (count #{count_found += 1}) \n"

            get_nomenclator_metadata[nomenclator_id] = {nomenclator_string: nomenclator_string, ident_qualifier: row['IdentQualifier'], file_id: row['FileID']}
          end

          import.set('SFNomenclatorIDToSFNomenclatorMetadata', get_nomenclator_metadata)

          puts = 'SFNomenclatorIDToSFNomenclatorMetadata'
          ap get_nomenclator_metadata
        end

      end
    end
  end
end


