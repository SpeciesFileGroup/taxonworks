######################## There are 3 tasks here:
# Run in this order:
# Nomenclator 1
# Nomenclator 2
# Nomenclator 3

# rake tw:db:restore backup_directory=/Users/proceps/src/sf/import/onedb2tw/snapshots/15_after_scrutinies/ file=localhost_2018-09-26_212447UTC.dump

namespace :tw do
  namespace :project_import do
    namespace :sf_import do
      require 'fileutils'
      require 'logged_task'
      namespace :citations do

        desc 'time rake tw:project_import:sf_import:citations:create_otu_cites user_id=1 data_directory=~/src/onedb2tw/working/'
        LoggedTask.define create_otu_cites: [:data_directory, :backup_directory, :environment, :user_id] do |logger|

          logger.info 'Creating citations for OTUs...'

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping
          # get_tw_project_id = import.get('SFFileIDToTWProjectID')
          # get_tw_taxon_name_id = import.get('SFTaxonNameIDToTWTaxonNameID')
          get_tw_otu_id = import.get('SFTaxonNameIDToTWOtuID') # Note this is an OTU associated with a SF.TaxonNameID (probably a bad taxon name)
          # get_taxon_name_otu_id = import.get('TWTaxonNameIDToOtuID') # Note this is the OTU offically associated with a real TW.taxon_name_id
          get_tw_source_id = import.get('SFRefIDToTWSourceID')
          # get_nomenclator_string = import.get('SFNomenclatorIDToSFNomenclatorString')
          get_nomenclator_metadata = import.get('SFNomenclatorIDToSFNomenclatorMetadata')
          get_cvt_id = import.get('CvtProjUriID')
          # get_containing_source_id = import.get('TWSourceIDToContainingSourceID') # use to determine if taxon_name_author must be created (orig desc only)
          # get_sf_taxon_name_authors = import.get('SFRefIDToTaxonNameAuthors') # contains ordered array of SF.PersonIDs
          ref_id_containing_id_hash = import.get('RefIDContainingHash')

          path = @args[:data_directory] + 'sfCites.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          count_found = 0
          error_counter = 0

          base_uri = 'http://speciesfile.org/legacy/'

          file.each_with_index do |row, i|
            sf_taxon_name_id = row['TaxonNameID']
            next if get_tw_otu_id[sf_taxon_name_id].nil?
            otu_id = get_tw_otu_id[sf_taxon_name_id]

            sf_ref_id = row['RefID']

            if ref_id_containing_id_hash[sf_ref_id].nil? # this RefID does not have a ContainingRefID
              add_different_authors = false # copy source_author list to taxon_name_author list
            else
              sf_ref_id = ref_id_containing_id_hash[sf_ref_id]
              add_different_authors = true # add taxon_name_authors for contained ref
            end

            source_id = get_tw_source_id[sf_ref_id].to_i
            next if source_id == 0

            otu = Otu.find(otu_id) # need otu object for project_id and
            project_id = otu.project_id.to_s

            seqnum = row['SeqNum']
            cite_pages = row['CitePages']

            logger.info "Working with TW.project_id: #{project_id}, SF.TaxonNameID #{sf_taxon_name_id} = TW.otu_id #{otu_id},SF.RefID #{sf_ref_id} = TW.source_id #{source_id}, SF.SeqNum #{seqnum}, cite_pages #{cite_pages} ( count #{count_found += 1} ) \n"

            # byebug

            # TODO: Is this dealing properly with cases where the first citation predates the original description?
            if seqnum == "1" # original citation already in; need to find it and update cite_pages
              citation = Citation.where(citation_object_type: 'Otu', citation_object_id: otu.id, is_original: true, source_id: source_id)
              if citation.nil?
                logger.error "Couldn't find original citation for OTU #{otu.id}, source_id: #{source_id}"
              end
              citation.update(pages: cite_pages)

            else # not the first citation for this name, create new citation
              citation = Citation.new(
                  source_id: source_id,
                  pages: row['CitePages'],
                  citation_object_type: 'Otu',
                  citation_object_id: otu.id,
                  project_id: project_id,
                  created_at: row['CreatedOn'],
                  updated_at: row['LastUpdate'],
                  created_by_id: get_tw_user_id[row['CreatedBy']],
                  updated_by_id: get_tw_user_id[row['ModifiedBy']]
              )
              begin
                citation.save!
              rescue ActiveRecord::RecordInvalid # citation not valid

                # yes I know this is ugly but it works
                if citation.errors.messages[:source_id].nil?
                  logger.error "Citation ERROR [TW.project_id: #{project_id}, SF.TaxonNameID #{row['TaxonNameID']}, SF.RefID #{sf_ref_id} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']}] (#{error_counter += 1}): " + citation.errors.full_messages.join(';')
                  next
                else # make pages unique and save again
                  if citation.errors.messages[:source_id].include?('has already been taken') # citation.errors.messages[:source_id][0] == 'has already been taken'
                    citation.pages = "#{row['CitePages']} [dupl #{row['SeqNum']}"
                    begin
                      citation.save!
                    rescue ActiveRecord::RecordInvalid
                      logger.error "Citation ERROR [TW.project_id: #{project_id}, SF.TaxonNameID #{row['TaxonNameID']}, SF.RefID #{sf_ref_id} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']}] (#{error_counter += 1}): " + citation.errors.full_messages.join(';')
                      next
                    end
                  else # citation error was not already been taken (other validation failure)
                    logger.error "Citation ERROR [TW.project_id: #{project_id}, SF.TaxonNameID #{row['TaxonNameID']}, SF.RefID #{sf_ref_id} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']}] (#{error_counter += 1}): " + citation.errors.full_messages.join(';')
                    next
                  end
                end
              end
            end

            if row['Note'].present?
              Note.create!(
                  text: row['Note'],
                  note_object_id: otu_id,
                  note_object_type: 'Otu',
                  project_id: project_id,
                  created_at: row['CreatedOn'],
                  updated_at: row['LastUpdate'],
                  created_by_id: get_tw_user_id[row['CreatedBy']],
                  updated_by_id: get_tw_user_id[row['ModifiedBy']]
              )
            end

            ##### ***** following needs debugging -- used to be citation attributes, now stand-alone objects
            # new_name_uri = (base_uri + 'new_name_status/' + row['NewNameStatusID']) unless row['NewNameStatusID'] == '0'
            # type_info_uri = (base_uri + 'type_info/' + row['TypeInfoID']) unless row['TypeInfoID'] == '0'
            # info_flag_status_uri = (base_uri + 'info_flag_status/' + row['InfoFlagStatus']) unless row['InfoFlagStatus'] == '0'
            #
            # new_name_cvt_id = get_cvt_id[project_id][new_name_uri]
            # type_info_cvt_id = get_cvt_id[project_id][type_info_uri]
            # info_flag_status_cvt_id = get_cvt_id[project_id][info_flag_status_uri]
            #
            # info_flags = row['InfoFlags'].to_i
            # citation_topics_attributes = []
            #
            # if info_flags > 0
            #   base_cite_info_flags_uri = (base_uri + 'cite_info_flags/') # + bit_position below
            #   cite_info_flags_array = Utilities::Numbers.get_bits(info_flags)
            #
            #   citation_topics_attributes = cite_info_flags_array.collect {|bit_position|
            #     {topic_id: get_cvt_id[project_id][base_cite_info_flags_uri + bit_position.to_s],
            #      project_id: project_id,
            #      created_at: row['CreatedOn'],
            #      updated_at: row['LastUpdate'],
            #      created_by_id: get_tw_user_id[row['CreatedBy']],
            #      updated_by_id: get_tw_user_id[row['ModifiedBy']]
            #     }
            #   }
            #
            #   CitationTopics.create!(citation_topics_attributes)
            # end
            #
            # ## NewNameStatus: As tags to citations, create 16 keywords for each project, set up in case statement; test for NewNameStatusID > 0
            # ## TypeInfo: As tags to citations, create n keywords for each project, set up in case statement (2364 cases!)
            # # tags_attributes: [
            # #     #  {keyword_id: (row['NewNameStatus'].to_i > 0 ?
            # # ControlledVocabularyTerm.where('uri LIKE ? and project_id = ?', "%/new_name_status/#{row['NewNameStatusID']}", project_id).limit(1).pluck(:id).first : nil), project_id: project_id},
            # #     #  {keyword_id: (row['TypeInfoID'].to_i > 0 ? ControlledVocabularyTerm.where('uri LIKE ? and project_id = ?', "%/type_info/#{row['TypeInfoID']}", project_id).limit(1).pluck(:id).first : nil), project_id: project_id}
            # #     {keyword_id: (new_name_uri ? new_name_cvt_id : nil), project_id: project_id},
            # #     {keyword_id: (type_info_uri ? Keyword.where('uri = ? AND project_id = ?', type_info_uri, project_id).limit(1).pluck(:id).first : nil), project_id: project_id}
            # #
            # # ],
            # ## InfoFlagStatus: Add confidence, 1 = partial data or needs review, 2 = complete data
            #
            # Tag.create!(keyword_id: new_name_cvt_id, tag_object: otu, project_id: project_id)
            # Tag.create!(keyword_id: type_info_cvt_id, tag_object: otu, project_id: project_id)
            # Tag.create!(keyword_id: info_flag_status_cvt_id, tag_object: otu, project_id: project_id)


            ### After citation updated or created

            ## Nomenclator: DataAttribute of citation, NomenclatorID > 0
            if row['NomenclatorID'] != '0' # OR could value: be evaluated below based on NomenclatorID?
              # byebug
              da = DataAttribute.create!(type: 'ImportAttribute',
                                         # attribute_subject: citation.citation_object, # replaces next two lines
                                         attribute_subject_id: otu_id,
                                         attribute_subject_type: 'Otu',
                                         import_predicate: 'Nomenclator',
                                         value: "#{get_nomenclator_metadata[row['NomenclatorID']]['nomenclator_string']} from source_id #{source_id}",
                                         project_id: project_id,
                                         created_at: row['CreatedOn'],
                                         updated_at: row['LastUpdate'],
                                         created_by_id: get_tw_user_id[row['CreatedBy']],
                                         updated_by_id: get_tw_user_id[row['ModifiedBy']]
              )
            end
          end

        end


        # def nomenclator_is_original_combination?(protonym, nomenclator_string)
        #   protonym.cached_original_combination == "<i>#{nomenclator_string}</i>"
        # end
        #
        # def nomenclator_is_current_name?(protonym, nomenclator_string)
        #   protonym.cached == nomenclator_string
        # end
        #
        # def m_original_combination(kn)
        #   return false, nil if !kn[:is_original_combination]
        #
        #   id = kn[:protonym].id
        #   kn[:cr].disambiguate_combination(genus: id, subgenus: id, species: id, subspecies: id, variety: id, form: id)
        #   kn[:protonym].build_original_combination_from_biodiversity(kn[:cr], kn[:housekeeping_params])
        #   kn[:protonym].save!
        #   return true, kn[:protonym]
        # end
        #
        # def m_single_match(kn) # test for single match
        #   potential_matches = TaxonName.where(cached: kn[:nomenclator_string], project_id: kn[:project_id])
        #   if potential_matches.count == 1
        #     puts 'm_single_match'
        #     return true, potential_matches.first
        #   end
        #   return false, nil
        # end
        #
        # def m_unambiguous(kn) # test combination is unambiguous and has genus
        #   if kn[:cr].is_unambiguous?
        #     if kn[:cr].genus
        #       puts 'm_unambiguous'
        #       return true, kn[:cr].combination
        #     end
        #   end
        #   return false, nil
        # end
        #
        # def m_current_species_homonym(kn) # test known genus and current species homonym
        #   if kn[:protonym].rank == "species"
        #     a = kn[:cr].disambiguate_combination(species: kn[:protonym].id)
        #     if a.get_full_name == kn[:nomenclator_string]
        #       puts 'm_current_species_homonym'
        #       return true, a
        #     end
        #   end
        #   return false, nil
        # end
        #
        #
        # # Returns a symbol/name of the decision to
        # # be taken for the row in question
        # def decide(knowns)
        #
        #
        # end
        #
        # # something that can be called in decide
        # def decide_method_a
        #
        # end
        #


        ###################################################################################################### Nomenclator 1st pass
        ## NOTE: Nomenclator 1, 2, & 3 are run in this order
        # Prior to running next task:
        #   Which dump file to restore
        # desc 'time rake tw:project_import:sf_import:citations:create_citations user_id=1 data_directory=/Users/proceps/src/sf/import/onedb2tw/working/'
        desc 'time rake tw:project_import:sf_import:citations:create_citations user_id=1 data_directory=~/src/onedb2tw/working/'
        LoggedTask.define create_citations: [:data_directory, :backup_directory, :environment, :user_id] do |logger|


          logger.info 'Creating citations...'

          # NOTE: Commented code below because it is overriding :user_id task
          # Current.project_id = 2
          # Current.user_id = 1
          # pwd = rand(36 ** 10).to_s(36)
          # @proceps = User.where(email: 'arboridia@gmail.com').first
          # @proceps = User.create(email: 'arboridia@gmail.com', password: pwd, password_confirmation: pwd, name: 'proceps', is_administrator: true, self_created: true, is_flagged_for_password_reset: true) if @proceps.nil?
          # pm = ProjectMember.create(user: @proceps, project_id: Current.project_id, is_project_administrator: true)

          # Current.user_id = @proceps.id
          # Current.project_id = nil

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
          ref_id_containing_id_hash = import.get('RefIDContainingHash')
          # get_containing_source_id = import.get('TWSourceIDToContainingSourceID') # use to determine if taxon_name_author must be created (orig desc only)
          # get_sf_taxon_name_authors = import.get('SFRefIDToTaxonNameAuthors') # contains ordered array of SF.PersonIDs
          # get_tw_person_id = import.get('SFPersonIDToTWPersonID')
          # get_sf_file_id = import.get('SFTaxonNameIDToSFFileID')

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
##################### next two lines were disabled

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
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

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
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

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
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

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
            a.merge!('rank_qualified' => row['RankQualified']) unless row['RankQualified'] == '0'
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

          no_nomenclator_keywords = {}
          get_tw_project_id.each_value do |project_id|
            k = Keyword.create(
                name: 'No NomenclatorID',
                definition: 'No NomenclatorID is provided in the original SF database',
                project_id: project_id)
            no_nomenclator_keywords[project_id] = k
          end


          cites_id_done = {}
          nomenclator_is_synonym_lut = {}
          missing_cites = []

          file_ids = Set[]
          CSV.foreach(@args[:data_directory] + 'sfCites.txt', col_sep: "\t", headers: true, encoding: 'BOM|UTF-8').each do |row|
            file_ids << row['FileID']
          end

          synonym_taxa = {}
          CSV.foreach(@args[:data_directory] + 'tblTaxa.txt', col_sep: "\t", headers: true, encoding: 'BOM|UTF-8').each do |row|
            synonym_taxa[row['TaxonNameID']] = {
              rank: row['RankID'].to_i
            } if row['NameStatus'] == '7' and ["10", "5"].include?(row['RankID']) # TODO:  Allow RankID 20 and 18 when fully thought through
          end

          # Runs in parallel only if PARALLEL_PROCESSOR_COUNT is explicitely set (screen output is suboptimal and logger summary won't work properly)
          logger.info "sfCites.txt processing begins..."
          cites_id_done, missing_cites, new_name_status = Parallel.map(file_ids, in_processes: ENV['PARALLEL_PROCESSOR_COUNT'].to_i || 0) do |file_id|
            ['', 'genus', 'subgenus', 'species', 'subspecies', 'infrasubspecies', 'synonym'].each do |rank_pass|
   #           ['species',  'synonym'].each do |rank_pass|

              path = @args[:data_directory] + 'sfCites.txt'
              print "\nsfCites.txt Working on: #{rank_pass}\n"
              raise "file #{path} not found" if not File.exists?(path)
              file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

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
                next unless row['FileID'] == file_id

                i += 1
  #              next if i < 480000
                print "\r#{i}"
                next if cites_id_done[row['TaxonNameID'].to_s + '_' + row['SeqNum'].to_s]

                if excluded_taxa.include? row['TaxonNameID']
                  cites_id_done[row['TaxonNameID'].to_s + '_' + row['SeqNum'].to_s] = true
                  missing_cites << [row['FileID'], row['TaxonNameID'], row['SeqNum'], "EXCLUDED_TAXA"]
                  next
                end

                if skipped_file_ids.include? row['FileID'].to_i
                  cites_id_done[row['TaxonNameID'].to_s + '_' + row['SeqNum'].to_s] = true
                  missing_cites << [row['FileID'], row['TaxonNameID'], row['SeqNum'], "EXCLUDED_FILE_ID"]
                  next
                end

                taxon_name_id = get_tw_taxon_name_id[row['TaxonNameID']] # cannot to_i because if nil, nil.to_i = 0
                taxon_name_id1 = nil

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
                  missing_cites << [row['FileID'], row['TaxonNameID'], row['SeqNum'], "TAXON_NOT_IMPORTED"]
                  next
                end

                source_id = get_tw_source_id[row['RefID']].to_i
                if source_id == 0
                  source_id = get_tw_source_id[ref_id_containing_id_hash[row['RefID']]].to_i
                  if source_id == 0
                    cites_id_done[row['TaxonNameID'].to_s + '_' + row['SeqNum'].to_s] = true
                    missing_cites << [row['FileID'], row['TaxonNameID'], row['SeqNum'], "SOURCE_MISSING"]
                    logger.error "RefID = #{row['RefID']} not mapped to TW source"
                    next
                  end
                  logger.warn "Using TW source for containing ref of (RefID = #{row['RefID']})"
                end

                nomenclator_id = row['NomenclatorID']

                nomenclator_components = {}
                nomenclator_components[:genus] = nomenclator_ids[nomenclator_id.to_i].dig('genus', 0)
                nomenclator_components[:subgenus] = nomenclator_ids[nomenclator_id.to_i].dig('subgenus', 0)
                nomenclator_components[:species] = nomenclator_ids[nomenclator_id.to_i].dig('species', 0)
                nomenclator_components[:subspecies] = nomenclator_ids[nomenclator_id.to_i].dig('subspecies', 0)
                nomenclator_components[:infrasubspecies] = nomenclator_ids[nomenclator_id.to_i].dig('infrasubspecies', 0)

                nomenclator_string = nomenclator_components.values.compact.join('_') # TODO: Even earlier code didn't consider incomplete nomenclators. Is it a problem?
                nomenclator_components[:subgenus] = "(#{nomenclator_components[:subgenus]})" if nomenclator_components[:subgenus]

                nomenclator_is_synonym = (
                  row['NewNameStatusID'] == '3' ||
                  ['synonym', 'syn.', 'syn', 'syn.nov.', 'syn. nov.'].include?(row['Note'].squish.downcase) ||
                  row['Note'].downcase.include?('synonym') ||
                  row['Note'].downcase.include?('syn.')
                )

                # Assume synonym when stem compare of taxon against nomenclator doesn't match (AKA "virtual syn. note")
                if !nomenclator_is_synonym && synonym_taxa[row['TaxonNameID']]
                  taxon_name_parsed = Biodiversity::Parser.parse(TaxonName.find(taxon_name_id).cached)
                  nomenclator_parsed = Biodiversity::Parser.parse(nomenclator_components.values.join(' '))
                  taxon_name_stem = taxon_name_parsed.dig(:canonicalName, :stem)&.split(" ")&.last
                  nomenclator_stem = nomenclator_parsed.dig(:canonicalName, :stem)&.split(" ")&.last

                  nomenclator_is_synonym = taxon_name_stem && nomenclator_stem && (taxon_name_stem != nomenclator_stem) &&
                    nomenclator_components[:genus] && nomenclator_components[:species] && # Just in case somehow missing data ended up parsed "correctly"
                    taxon_name_parsed.dig(:details, 0, :specificEpithet) &&
                    nomenclator_parsed.dig(:details, 0, :specificEpithet) && # NOTE: SOME non-latinized misspellings won't pass this test (like Dreyfusia nüßlini)
                    [*0..2, *6..12, 22].include?(row['NewNameStatusID'].to_i)

                  logger.warn(
                    "VIRTUAL_NOTE[rank_pass='#{rank_pass}']: FileID=#{row['FileID']}, TaxonNameID=#{row['TaxonNameID']}, SeqNum=#{row['SeqNum']}, " +
                    "taxon_name_stem=#{taxon_name_stem}, nomenclator_stem=#{nomenclator_stem}",
                    {
                      taxon_name: [synonym_taxa.dig(row['TaxonNameID'], :rank), TaxonName.find(taxon_name_id).cached, taxon_name_stem],
                      nomenclator: [row['NewNameStatusID'], nomenclator_components, nomenclator_stem]
                    }
                  ) if nomenclator_is_synonym
                end

                nomenclator_is_synonym_lut[ [row["TaxonNameID"], row["NomenclatorID"]] ] = row["SeqNum"] if nomenclator_is_synonym

                if !nomenclator_is_synonym && synonym_taxa[row['TaxonNameID']]
                  if nomenclator_is_synonym_lut[ [row["TaxonNameID"], row["NomenclatorID"]] ].to_i < row["SeqNum"].to_i
                    nomenclator_is_synonym = true

                    logger.warn(
                      "FORWARDED_VIRTUAL_NOTE[rank_pass='#{rank_pass}']: FileID=#{row['FileID']}, TaxonNameID=#{row['TaxonNameID']}, SeqNum=#{row['SeqNum']}"
                    )
                  end
                end

                # if nomenclator_id != '0' && get_nomenclator_metadata[nomenclator_id]
                #
                #   nomenclator_ident_qualifier = get_nomenclator_metadata[nomenclator_id]['ident_qualifier']
                #
                #   unless nomenclator_ids[nomenclator_id.to_i]['qualifier'].blank?
                #
                #     project_id = protonym.project_id.to_s #  TaxonName.find(taxon_name_id).project_id.to_s # forced to string for hash value
                #     Current.project_id = project_id
                #     Note.create!(
                #         note_object_type: protonym,
                #         note_object_id: taxon_name_id,
                #         text: "Citation to '#{get_sf_verbatim_ref[row['RefID']]}' not created because accompanying nomenclator ('#{nomenclator_string}') contains irrelevant data ('#{nomenclator_ident_qualifier}')",
                #         project_id: project_id,
                #         created_at: row['CreatedOn'], # housekeeping data from citation not created
                #         updated_at: row['LastUpdate'],
                #         created_by_id: get_tw_user_id[row['CreatedBy']],
                #         updated_by_id: get_tw_user_id[row['ModifiedBy']]
                #     )
                #     cites_id_done[row['TaxonNameID'].to_s + '_' + row['SeqNum'].to_s] = true
                #     next
                #   end
                # end

                if rank_pass == '' && nomenclator_id != '0'
                  next
                elsif rank_pass == 'genus' && (!nomenclator_ids[nomenclator_id.to_i]['subgenus'].nil? || !nomenclator_ids[nomenclator_id.to_i]['species'].nil? || !nomenclator_ids[nomenclator_id.to_i]['subspecies'].nil? || !nomenclator_ids[nomenclator_id.to_i]['infrasubspecies'].nil?)
                  next
                elsif rank_pass == 'subgenus' && (!nomenclator_ids[nomenclator_id.to_i]['species'].nil? || !nomenclator_ids[nomenclator_id.to_i]['subspecies'].nil? || !nomenclator_ids[nomenclator_id.to_i]['infrasubspecies'].nil?)
                  next
                elsif rank_pass == 'species' && (!nomenclator_ids[nomenclator_id.to_i]['subspecies'].nil? || !nomenclator_ids[nomenclator_id.to_i]['infrasubspecies'].nil?)
                  next
                elsif rank_pass == 'subspecies' && (!nomenclator_ids[nomenclator_id.to_i]['infrasubspecies'].nil?)
                  next
                elsif rank_pass != 'synonym' && nomenclator_is_synonym
                  next
                end

                protonym = TaxonName.find(taxon_name_id)


  #              if row['TaxonNameID'].to_s == '1132873' # || row['TaxonNameID'].to_s ==  '1128514'
  #                 byebug
  #              else
  #                next
  #              end


                #1132873 second citation of the synonym relationship is missing
  #
                #1128515 does not change to Adjective with the original citation.
  #
                # 1111197 - duplicate record for protonym without TNR
  #               1140778 - first synonym citation is missing
  #              1132873 - second synonym citation is missin

           #    '1137725' Barbitistes alpinus  row "stat. nov., neotype designation"" creates a new protonym without citation (second record) ; original species subspecies relationship is not created
           #     '1137729' "Barbitistes serricaudus" taxon name with different ending, but no citation
                project_id = protonym.project_id.to_s #  TaxonName.find(taxon_name_id).project_id.to_s # forced to string for hash value
                Current.project_id = project_id.to_i
                citation_on_otu = false
                new_protonym = false
                skip_citation = false

                citation_housekeeping_attributes = {
                  created_at: row['CreatedOn'],
                  updated_at: row['LastUpdate'],
                  created_by_id: get_tw_user_id[row['CreatedBy']],
                  updated_by_id: get_tw_user_id[row['ModifiedBy']]
                }

                citation_common_attributes = {
                  source_id: source_id,
                  pages: row['CitePages'],
                  project_id: project_id.to_i,
                  citation_topics_attributes: Utilities::Numbers.get_bits(row['InfoFlags'].to_i).map do |bit_position|
                    {
                      topic_id: get_cvt_id[project_id]["#{base_uri}cite_info_flags/#{bit_position}"],
                      project_id: project_id.to_i
                    }.merge!(citation_housekeeping_attributes)
                  end
                }.merge!(citation_housekeeping_attributes)

                if row['NomenclatorID'] !='0' && nomenclator_ids[nomenclator_id.to_i] && nomenclator_ids[nomenclator_id.to_i]['genus'] && tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['genus'][0]].nil?
                  pr = Protonym.create(name: nomenclator_ids[nomenclator_id.to_i]['genus'][0], rank_class: Ranks.lookup(:iczn, 'Genus'), project_id: project_id, parent_id: protonym.root.id, created_by_id: get_tw_user_id[row['CreatedBy']], updated_by_id: get_tw_user_id[row['ModifiedBy']], created_at: row['CreatedOn'], updated_at: row['LastUpdate'])
                  if pr.id.nil?
                    citation_on_otu = true
                  else
                    pr.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus', subject_taxon_name: pr, project_id: pr.id)
                    pr.save
                    tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['genus'][0]] = pr.id
                    tw_taxa_ids[project_id + '_' + pr.name] = pr.id if tw_taxa_ids[project_id + '_' + pr.name].nil?
                    if nomenclator_ids[nomenclator_id.to_i]['subgenus'].nil? && nomenclator_ids[nomenclator_id.to_i]['species'].nil? && nomenclator_ids[nomenclator_id.to_i]['subspecies'].nil? && nomenclator_ids[nomenclator_id.to_i]['infrasubspecies'].nil?
                      pr.parent_id = protonym.parent_id
                      pr.rank_class = protonym.rank_class
                      pr.save
                      tr = pr.taxon_name_relationships.create(object_taxon_name: protonym, type: 'TaxonNameRelationship::Iczn::Invalidating', project_id: project_id)
                      byebug if tr.id.nil?
                      protonym = pr
                      taxon_name_id = pr.id
                      tw_taxa_ids[project_id + '_' + nomenclator_string + '_' + protonym.cached_valid_taxon_name_id.to_s] = protonym.id if tw_taxa_ids[project_id + '_' + nomenclator_string + '_' + protonym.cached_valid_taxon_name_id.to_s]
                      new_protonym = true
                    end
                  end
                end
                if row['NomenclatorID'] !='0' && nomenclator_ids[nomenclator_id.to_i] && nomenclator_ids[nomenclator_id.to_i]['subgenus'] && tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['subgenus'][0]].nil?
                  pr = Protonym.create(name: nomenclator_ids[nomenclator_id.to_i]['subgenus'][0], rank_class: Ranks.lookup(:iczn, 'Subgenus'), project_id: project_id, parent_id: protonym.root.id, created_by_id: get_tw_user_id[row['CreatedBy']], updated_by_id: get_tw_user_id[row['ModifiedBy']], created_at: row['CreatedOn'], updated_at: row['LastUpdate'])
                  if pr.id.nil?
                    citation_on_otu = true
                  else
                    pr.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus', subject_taxon_name: pr, project_id: project_id)
                    pr.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['genus'][0]]), project_id: project_id) if nomenclator_ids[nomenclator_id.to_i]['genus'] && pr.original_genus.nil?
                    pr.save
                    tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['subgenus'][0]] = pr.id
                    tw_taxa_ids[project_id + '_' + pr.name] = pr.id if tw_taxa_ids[project_id + '_' + pr.name].nil?
                    if nomenclator_ids[nomenclator_id.to_i]['species'].nil? && nomenclator_ids[nomenclator_id.to_i]['subspecies'].nil? && nomenclator_ids[nomenclator_id.to_i]['infrasubspecies'].nil?
                      pr.parent_id = protonym.parent_id
                      pr.rank_class = protonym.rank_class
                      pr.save
                      tr = pr.taxon_name_relationships.create(object_taxon_name: protonym, type: 'TaxonNameRelationship::Iczn::Invalidating', project_id: project_id)
                      byebug if tr.id.nil?
                      protonym = pr
                      taxon_name_id = pr.id
                      tw_taxa_ids[project_id + '_' + nomenclator_string + '_' + protonym.cached_valid_taxon_name_id.to_s] = protonym.id if tw_taxa_ids[project_id + '_' + nomenclator_string + '_' + protonym.cached_valid_taxon_name_id.to_s].nil?
                      new_protonym = true
                    end
                  end
                end
                if nomenclator_ids[nomenclator_id.to_i] && nomenclator_ids[nomenclator_id.to_i]['species'] && nomenclator_ids[nomenclator_id.to_i]['genus'] && protonym && tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['genus'][0] + '_' + nomenclator_ids[nomenclator_id.to_i]['species'][0]].nil?
                  if nomenclator_ids[nomenclator_id.to_i]['subgenus'] && !nomenclator_ids[nomenclator_id.to_i]['subgenus'][0].nil? && !tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['subgenus'][0] + '_' + nomenclator_ids[nomenclator_id.to_i]['species'][0]].nil?
                    tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['genus'][0] + '_' + nomenclator_ids[nomenclator_id.to_i]['species'][0]] = tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['subgenus'][0] + '_' + nomenclator_ids[nomenclator_id.to_i]['species'][0]]
                  end
                end
                if row['NomenclatorID'] !='0' && nomenclator_ids[nomenclator_id.to_i] && nomenclator_ids[nomenclator_id.to_i]['species'] && nomenclator_ids[nomenclator_id.to_i]['genus'] && protonym && tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['genus'][0] + '_' + nomenclator_ids[nomenclator_id.to_i]['species'][0]].nil?
                  if nomenclator_ids[nomenclator_id.to_i]['subspecies'] && nomenclator_ids[nomenclator_id.to_i]['infrasubspecies'].nil? && nomenclator_ids[nomenclator_id.to_i]['species'][0] != nomenclator_ids[nomenclator_id.to_i]['subspecies'][0]
                    tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['genus'][0] + '_' + nomenclator_ids[nomenclator_id.to_i]['species'][0]] = protonym.id
                  elsif nomenclator_ids[nomenclator_id.to_i]['infrasubspecies'] && nomenclator_ids[nomenclator_id.to_i]['species'][0] == nomenclator_ids[nomenclator_id.to_i]['infrasubspecies'][0]
                    tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['genus'][0] + '_' + nomenclator_ids[nomenclator_id.to_i]['species'][0]] = protonym.id
                  else
                    pr = Protonym.new(name: nomenclator_ids[nomenclator_id.to_i]['species'][0], rank_class: Ranks.lookup(:iczn, 'Species'), project_id: project_id, parent_id: protonym.root.id, created_by_id: get_tw_user_id[row['CreatedBy']], updated_by_id: get_tw_user_id[row['ModifiedBy']], created_at: row['CreatedOn'], updated_at: row['LastUpdate'])
                    if orig_desc_source_id != [source_id, protonym.id] && source_id == protonym.source.try(:id) && protonym.name_with_alternative_spelling == pr.name_with_alternative_spelling && nomenclator_ids[nomenclator_id.to_i]['genus'][0] == protonym.original_genus.try(:name)
                      ge = protonym.ancestor_at_rank('genus')
                      unless ge.nil?
                        if protonym.name.ends_with?('us')
                          ge.taxon_name_classifications.create(type: 'TaxonNameClassification::Latinized::Gender::Masculine')
                        elsif protonym.name.ends_with?('um')
                          ge.taxon_name_classifications.create(type: 'TaxonNameClassification::Latinized::Gender::Neuter')
                        elsif protonym.name.ends_with?('a')
                          ge.taxon_name_classifications.create(type: 'TaxonNameClassification::Latinized::Gender::Feminine')
                        end
                      end

                      protonym.name = pr.name
                      protonym.taxon_name_classifications.new(type: 'TaxonNameClassification::Latinized::PartOfSpeech::Adjective')
                      protonym.save
                      tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['genus'][0] + '_' + nomenclator_ids[nomenclator_id.to_i]['species'][0]] = protonym.id if tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['genus'][0] + '_' + nomenclator_ids[nomenclator_id.to_i]['species'][0]].nil?
                      tw_taxa_ids[project_id + '_' + nomenclator_string + '_' + protonym.cached_valid_taxon_name_id.to_s] = protonym.id if tw_taxa_ids[project_id + '_' + nomenclator_string + '_' + protonym.cached_valid_taxon_name_id.to_s].nil?
                    elsif tw_taxa_ids[project_id + '_' + nomenclator_string + '_' + protonym.cached_valid_taxon_name_id.to_s].nil?
                      pr.save
                      if pr.id.nil?
                        citation_on_otu = true
                      else
                        pr.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSpecies', subject_taxon_name: pr, project_id: project_id)
                        pr.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['subgenus'][0]]), project_id: project_id) if nomenclator_ids[nomenclator_id.to_i]['subgenus']
                        if nomenclator_ids[nomenclator_id.to_i]['genus'] && !tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['genus'][0]].blank? && pr.original_genus.nil?
                          pr.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['genus'][0]]), project_id: project_id)
   #                     elsif nomenclator_ids[nomenclator_id.to_i]['genus'] && pr.original_genus.nil?
   #                       byebug
                        end

                        pr.save
                        tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['genus'][0] + '_' + pr.name] = pr.id if tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['genus'][0] + '_' + pr.name].nil?
                        if nomenclator_ids[nomenclator_id.to_i]['subspecies'].nil? && nomenclator_ids[nomenclator_id.to_i]['infrasubspecies'].nil?
                          pr.parent_id = protonym.parent_id
                          pr.rank_class = protonym.rank_class
                          pr.save
                          tr = pr.taxon_name_relationships.create(object_taxon_name: protonym, type: 'TaxonNameRelationship::Iczn::Invalidating', project_id: project_id)
                          byebug if tr.id.nil?
                          protonym = pr
                          taxon_name_id = pr.id
                          tw_taxa_ids[project_id + '_' + nomenclator_string + '_' + protonym.cached_valid_taxon_name_id.to_s] = protonym.id if tw_taxa_ids[project_id + '_' + nomenclator_string + '_' + protonym.cached_valid_taxon_name_id.to_s].nil?
                          new_protonym = true
                        end
                      end
                    end
                  end
                end
                if row['NomenclatorID'] !='0' && nomenclator_ids[nomenclator_id.to_i] && nomenclator_ids[nomenclator_id.to_i]['species'] && nomenclator_ids[nomenclator_id.to_i]['genus'] && protonym && tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['genus'][0] + '_' + nomenclator_ids[nomenclator_id.to_i]['species'][0]].nil?
                  gen = protonym.ancestor_at_rank('genus')
                  if !gen.nil?
                    pr = tw_taxa_ids[project_id + '_' + gen.name + '_' + nomenclator_ids[nomenclator_id.to_i]['species'][0]]
                    tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['genus'][0] + '_' + nomenclator_ids[nomenclator_id.to_i]['species'][0]] = pr if pr
                  end
                end
                if row['NomenclatorID'] !='0' && nomenclator_ids[nomenclator_id.to_i] && nomenclator_ids[nomenclator_id.to_i]['subspecies'] && nomenclator_ids[nomenclator_id.to_i]['genus'] && protonym && tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['genus'][0] + '_' + nomenclator_ids[nomenclator_id.to_i]['subspecies'][0]].nil?
                  pr = Protonym.new(name: nomenclator_ids[nomenclator_id.to_i]['subspecies'][0], rank_class: Ranks.lookup(:iczn, 'Subspecies'), project_id: project_id, parent_id: protonym.root.id, created_by_id: get_tw_user_id[row['CreatedBy']], updated_by_id: get_tw_user_id[row['ModifiedBy']], created_at: row['CreatedOn'], updated_at: row['LastUpdate'])
                  if orig_desc_source_id != [source_id, protonym.id] && source_id == protonym.source.try(:id) && protonym.name_with_alternative_spelling == pr.name_with_alternative_spelling && nomenclator_ids[nomenclator_id.to_i]['genus'][0] == protonym.original_genus.try(:name)
                    ge = protonym.ancestor_at_rank('genus')
                    unless ge.nil?
                      if protonym.name.ends_with?('us')
                        ge.taxon_name_classifications.create(type: 'TaxonNameClassification::Latinized::Gender::Masculine')
                      elsif protonym.name.ends_with?('um')
                        ge.taxon_name_classifications.create(type: 'TaxonNameClassification::Latinized::Gender::Neuter')
                      elsif protonym.name.ends_with?('a')
                        ge.taxon_name_classifications.create(type: 'TaxonNameClassification::Latinized::Gender::Feminine')
                      end
                    end

                    protonym.name = pr.name
                    protonym.taxon_name_classifications.new(type: 'TaxonNameClassification::Latinized::PartOfSpeech::Adjective')
                    protonym.save
                    tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['genus'][0] + '_' + nomenclator_ids[nomenclator_id.to_i]['subspecies'][0]] = protonym.id if tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['genus'][0] + '_' + nomenclator_ids[nomenclator_id.to_i]['subspecies'][0]].nil?
                  elsif tw_taxa_ids[project_id + '_' + nomenclator_string + '_' + protonym.cached_valid_taxon_name_id.to_s].nil?
                    pr.save
                    if pr.id.nil?
                      citation_on_otu = true
                    else
                      pr.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSubspecies', subject_taxon_name: pr, project_id: project_id)
                      pr.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSpecies', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['genus'][0] + '_' + nomenclator_ids[nomenclator_id.to_i]['species'][0]]), project_id: project_id) if nomenclator_ids[nomenclator_id.to_i]['species']
                      pr.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['subgenus'][0]]), project_id: project_id) if nomenclator_ids[nomenclator_id.to_i]['subgenus']
                      pr.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['genus'][0]]), project_id: project_id) if nomenclator_ids[nomenclator_id.to_i]['genus'] && pr.original_genus.nil?
                      pr.save
                      tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['genus'][0] + '_' + pr.name] = pr.id if tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['genus'][0] + '_' + pr.name].nil?
                      if nomenclator_ids[nomenclator_id.to_i]['infrasubspecies'].nil?
                        pr.parent_id = protonym.parent_id
                        pr.rank_class = protonym.rank_class
                        pr.save
                        tr = pr.taxon_name_relationships.create(object_taxon_name: protonym, type: 'TaxonNameRelationship::Iczn::Invalidating', project_id: project_id)
                        byebug if tr.id.nil?
                        protonym = pr
                        taxon_name_id = pr.id
                        tw_taxa_ids[project_id + '_' + nomenclator_string + '_' + protonym.cached_valid_taxon_name_id.to_s] = protonym.id if tw_taxa_ids[project_id + '_' + nomenclator_string + '_' + protonym.cached_valid_taxon_name_id.to_s].nil?
                        new_protonym = true
                      end
                    end
                  end
                end
                if row['NomenclatorID'] !='0' && nomenclator_ids[nomenclator_id.to_i] && protonym.is_species_rank? && nomenclator_ids[nomenclator_id.to_i]['species'].nil?
                  citation_on_otu = true
                end

                new_name_uri = (base_uri + 'new_name_status/' + row['NewNameStatusID']) unless row['NewNameStatusID'] == '0'
                type_info_uri = (base_uri + 'type_info/' + row['TypeInfoID']) unless row['TypeInfoID'] == '0'
                info_flag_status_uri = (base_uri + 'info_flag_status/' + row['InfoFlagStatus']) unless row['InfoFlagStatus'] == '0'

                new_name_cvt_id = get_cvt_id[project_id][new_name_uri]
                type_info_cvt_id = get_cvt_id[project_id][type_info_uri]
                info_flag_status_cvt_id = get_cvt_id[project_id][info_flag_status_uri]

                qualifier_string = nil
                nomenclator_ident_qualifier = nomenclator_ids[nomenclator_id.to_i].blank? ? nil : nomenclator_ids[nomenclator_id.to_i]['qualifier']
                if nomenclator_ids[nomenclator_id.to_i] && !nomenclator_ident_qualifier.blank?
                  genus = nomenclator_ids[nomenclator_id.to_i]['genus'].blank? ? nil : nomenclator_ids[nomenclator_id.to_i]['genus'][0]
                  genus = nomenclator_ident_qualifier + ' ' + genus.to_s if nomenclator_ids[nomenclator_id.to_i]['rank_qualified'] == '20'
                  subgenus = nomenclator_ids[nomenclator_id.to_i]['subgenus'].blank? ? nil : nomenclator_ids[nomenclator_id.to_i]['subgenus'][0]
                  subgenus = nomenclator_ident_qualifier + ' ' + subgenus.to_s if nomenclator_ids[nomenclator_id.to_i]['rank_qualified'] == '18'
                  subgenus = '(' + subgenus + ')' unless subgenus.blank?
                  species = nomenclator_ids[nomenclator_id.to_i]['species'].blank? ? nil : nomenclator_ids[nomenclator_id.to_i]['species'][0]
                  species = nomenclator_ident_qualifier + ' ' + species.to_s if nomenclator_ids[nomenclator_id.to_i]['rank_qualified'] == '10'
                  subspecies = nomenclator_ids[nomenclator_id.to_i]['subspecies'].blank? ? nil : nomenclator_ids[nomenclator_id.to_i]['subspecies'][0]
                  subspecies =  nomenclator_ident_qualifier + ' ' + subspecies.to_s if nomenclator_ids[nomenclator_id.to_i]['rank_qualified'] == '5'
                  infrasubspecies = nomenclator_ids[nomenclator_id.to_i]['infrasubspecies'].blank? ? nil : nomenclator_ids[nomenclator_id.to_i]['infrasubspecies'][0]
                  infrasubspecies = nomenclator_ident_qualifier + ' ' + infrasubspecies.to_s if nomenclator_ids[nomenclator_id.to_i]['rank_qualified'] == '3'
                  qualifier_string = [genus, subgenus, species, subspecies, infrasubspecies].compact.join(' ')
                end
                if citation_on_otu && nomenclator_ids[nomenclator_id.to_i]
                  genus = nomenclator_ids[nomenclator_id.to_i]['genus'].blank? ? nil : nomenclator_ids[nomenclator_id.to_i]['genus'][0]
                  subgenus = nomenclator_ids[nomenclator_id.to_i]['subgenus'].blank? ? nil : nomenclator_ids[nomenclator_id.to_i]['subgenus'][0]
                  subgenus = '(' + subgenus + ')' unless subgenus.blank?
                  species = nomenclator_ids[nomenclator_id.to_i]['species'].blank? ? nil : nomenclator_ids[nomenclator_id.to_i]['species'][0]
                  subspecies = nomenclator_ids[nomenclator_id.to_i]['subspecies'].blank? ? nil : nomenclator_ids[nomenclator_id.to_i]['subspecies'][0]
                  infrasubspecies = nomenclator_ids[nomenclator_id.to_i]['infrasubspecies'].blank? ? nil : nomenclator_ids[nomenclator_id.to_i]['infrasubspecies'][0]
                  citation_on_otu = [genus, subgenus, species, subspecies, infrasubspecies].compact.join(' ')
                end

                is_original = false

                citation = Citation.where(source_id: source_id, citation_object_type: 'TaxonName', citation_object_id: taxon_name_id, is_original: true).first

                cites_id_done[row['TaxonNameID'].to_s + '_' + row['SeqNum'].to_s] = true
                if source_id.nil?
                  missing_cites << [row['FileID'], row['TaxonNameID'], row['SeqNum'], "NO_SOURCE"]
                  next
                elsif !citation.nil? && citation.pages.blank? && orig_desc_source_id != [source_id, protonym.id]
                  orig_desc_source_id = [source_id, protonym.id] # prevents duplicate citation to same source being processed as original description
                  #citation.notes.create(text: row['Note'], project_id: project_id, created_by_id: get_tw_user_id[row['CreatedBy']], updated_by_id: get_tw_user_id[row['ModifiedBy']], created_at: row['CreatedOn'], updated_at: row['LastUpdate']) unless row['Note'].blank?

                  citation.update(pages: row['CitePages'])

                  unless citation.id.nil?
                    unless row['Note'].blank?
                      #n = protonym.notes.find_or_create_by(text: row['Note'], project_id: project_id, created_at: row['CreatedOn'], updated_at: row['LastUpdate'], created_by_id: get_tw_user_id[row['CreatedBy']], updated_by_id: get_tw_user_id[row['ModifiedBy']])
                      # n.citations.create!(source_id: citation.source_id, project_id: project_id, created_at: row['CreatedOn'], updated_at: row['LastUpdate'], created_by_id: get_tw_user_id[row['CreatedBy']], updated_by_id: get_tw_user_id[row['ModifiedBy']])
                      n = citation.notes.create(text: row['Note'], project_id: project_id, created_at: row['CreatedOn'], updated_at: row['LastUpdate'], created_by_id: get_tw_user_id[row['CreatedBy']], updated_by_id: get_tw_user_id[row['ModifiedBy']])
                    end
                    unless qualifier_string.blank?
                      n = citation.notes.create(text: 'Cited as ' + qualifier_string, project_id: project_id, created_at: row['CreatedOn'], updated_at: row['LastUpdate'], created_by_id: get_tw_user_id[row['CreatedBy']], updated_by_id: get_tw_user_id[row['ModifiedBy']])
                    end
                    unless new_name_cvt_id.blank?
                      #n = protonym.tags.find_or_create_by(keyword_id: new_name_cvt_id, project_id: project_id, created_by_id: get_tw_user_id[row['CreatedBy']], updated_by_id: get_tw_user_id[row['ModifiedBy']], created_at: row['CreatedOn'], updated_at: row['LastUpdate'])
                      #n.citations.create!(source_id: citation.source_id, project_id: project_id)
                      n = citation.tags.create(keyword_id: new_name_cvt_id, project_id: project_id, created_by_id: get_tw_user_id[row['CreatedBy']], updated_by_id: get_tw_user_id[row['ModifiedBy']], created_at: row['CreatedOn'], updated_at: row['LastUpdate'])
                    end
                    is_original = true
                    unless type_info_cvt_id.blank?
                      #n = protonym.tags.find_or_create_by(keyword_id: type_info_cvt_id, project_id: project_id, created_by_id: get_tw_user_id[row['CreatedBy']], updated_by_id: get_tw_user_id[row['ModifiedBy']], created_at: row['CreatedOn'], updated_at: row['LastUpdate'])
                      #n.citations.create!(source_id: citation.source_id, project_id: project_id)
                      n = citation.tags.create(keyword_id: type_info_cvt_id, project_id: project_id, created_by_id: get_tw_user_id[row['CreatedBy']], updated_by_id: get_tw_user_id[row['ModifiedBy']], created_at: row['CreatedOn'], updated_at: row['LastUpdate'])
                    end
                    unless info_flag_status_cvt_id.blank?
                      n = protonym.confidences.find_or_create_by(confidence_level_id: info_flag_status_cvt_id, project_id: project_id)
                      n.citations.create(source_id: citation.source_id, project_id: project_id, created_by_id: get_tw_user_id[row['CreatedBy']], updated_by_id: get_tw_user_id[row['ModifiedBy']], created_at: row['CreatedOn'], updated_at: row['LastUpdate'])
                    end
                  end

                  # logger.info "Citation found: citation.id = #{citation.id}, taxon_name_id = #{taxon_name_id}, cite_pages = '#{row['CitePages']}' (cite_found_counter = #{cite_found_counter += 1})"

                  #                if get_containing_source_id[source_id.to_s] && protonym.roles.nil? # create taxon_name_author role for contained Refs only
                  #                  Source.find(get_containing_source_id[source_id.to_s].to_i).roles.each do |person|
                  ##                    get_sf_taxon_name_authors[row['RefID']].each do |sf_person_id| # person_id from author_array
                  #                    protonym.roles.create!(
                  ##                        person_id: get_tw_person_id[sf_person_id],
                  #                        person: person,
                  #                        type: 'TaxonNameAuthor',
                  #                        project_id: project_id, # role is project_role
                  #                        )
                  #                  end
                  #                end

                  if protonym.rank_string == 'NomenclaturalRank::Iczn::SpeciesGroup::Species' && nomenclator_ids[nomenclator_id.to_i] && nomenclator_ids[nomenclator_id.to_i]['species'] && protonym.name != nomenclator_ids[nomenclator_id.to_i]['species'][0]
                    pr = Protonym.new(name: nomenclator_ids[nomenclator_id.to_i]['species'][0], rank_class: Ranks.lookup(:iczn, 'Species'), project_id: project_id, parent_id: protonym.root.id, created_by_id: get_tw_user_id[row['CreatedBy']], updated_by_id: get_tw_user_id[row['ModifiedBy']], created_at: row['CreatedOn'], updated_at: row['LastUpdate'])
                    if protonym.name_with_alternative_spelling == pr.name_with_alternative_spelling && nomenclator_ids[nomenclator_id.to_i] && nomenclator_ids[nomenclator_id.to_i]['genus'] && nomenclator_ids[nomenclator_id.to_i]['genus'][0] == protonym.original_genus.try(:name)
                      ge = protonym.ancestor_at_rank('genus')
                      unless ge.nil?
                        if protonym.name.ends_with?('us')
                          ge.taxon_name_classifications.create(type: 'TaxonNameClassification::Latinized::Gender::Masculine')
                        elsif protonym.name.ends_with?('um') || protonym.name.ends_with?('e')
                          ge.taxon_name_classifications.create(type: 'TaxonNameClassification::Latinized::Gender::Neuter')
                        elsif protonym.name.ends_with?('a')
                          ge.taxon_name_classifications.create(type: 'TaxonNameClassification::Latinized::Gender::Feminine')
                        end
                      end
                      protonym.name = pr.name
                      protonym.taxon_name_classifications.new(type: 'TaxonNameClassification::Latinized::PartOfSpeech::Adjective')
                    end
                  end

                  if rank_pass == 'genus' && nomenclator_ids[nomenclator_id.to_i]['genus'] && protonym.name == nomenclator_ids[nomenclator_id.to_i]['genus'][0]
                    protonym.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus', subject_taxon_name: protonym, project_id: project_id) && protonym.original_genus.nil?
                  elsif rank_pass == 'subgenus' && nomenclator_ids[nomenclator_id.to_i]['subgenus'] && protonym.name == nomenclator_ids[nomenclator_id.to_i]['subgenus'][0]
                    protonym.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus', subject_taxon_name: protonym, project_id: project_id)
                    protonym.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['genus'][0]]), project_id: project_id) if protonym.original_genus.nil? && nomenclator_ids[nomenclator_id.to_i] && nomenclator_ids[nomenclator_id.to_i]['genus'] && protonym.original_genus.nil?
                  elsif rank_pass == 'subgenus' && nomenclator_ids[nomenclator_id.to_i]['genus'] && protonym.name == nomenclator_ids[nomenclator_id.to_i]['genus'][0] && nomenclator_ids[nomenclator_id.to_i]['subgenus'].nil?
                    protonym.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus', subject_taxon_name: protonym, project_id: project_id)
                  elsif rank_pass == 'species' && nomenclator_ids[nomenclator_id.to_i]['species'] && protonym.name == nomenclator_ids[nomenclator_id.to_i]['species'][0]
                    protonym.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSpecies', subject_taxon_name: protonym, project_id: project_id)
                    protonym.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['subgenus'][0]]), project_id: project_id) if nomenclator_ids[nomenclator_id.to_i] && nomenclator_ids[nomenclator_id.to_i]['subgenus']
                    protonym.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['genus'][0]]), project_id: project_id) if protonym.original_genus.nil? && nomenclator_ids[nomenclator_id.to_i] && nomenclator_ids[nomenclator_id.to_i]['genus'] && protonym.original_genus.nil?
                  elsif rank_pass == 'subspecies' && nomenclator_ids[nomenclator_id.to_i]['subspecies'] && protonym.name == nomenclator_ids[nomenclator_id.to_i]['subspecies'][0]
                    protonym.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSubspecies', subject_taxon_name: protonym, project_id: project_id)
                    if nomenclator_ids[nomenclator_id.to_i] && nomenclator_ids[nomenclator_id.to_i]['subspecies'] && nomenclator_ids[nomenclator_id.to_i]['species'] && nomenclator_ids[nomenclator_id.to_i]['subspecies'][0] == nomenclator_ids[nomenclator_id.to_i]['species'][0]
                      protonym.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSpecies', subject_taxon_name: protonym, project_id: project_id)
                    elsif nomenclator_ids[nomenclator_id.to_i] && nomenclator_ids[nomenclator_id.to_i]['genus'] && nomenclator_ids[nomenclator_id.to_i]['species']
                      protonym.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSpecies', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['genus'][0] + '_' + nomenclator_ids[nomenclator_id.to_i]['species'][0]]), project_id: project_id)
                    end
                    protonym.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['subgenus'][0]]), project_id: project_id) if nomenclator_ids[nomenclator_id.to_i] && nomenclator_ids[nomenclator_id.to_i]['subgenus']
                    protonym.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['genus'][0]]), project_id: project_id) if protonym.original_genus.nil? && nomenclator_ids[nomenclator_id.to_i] && nomenclator_ids[nomenclator_id.to_i]['genus'] && protonym.original_genus.nil?
                  elsif rank_pass == 'infrasubspecies' && nomenclator_ids[nomenclator_id.to_i]['infrasubspecies'] && protonym.name == nomenclator_ids[nomenclator_id.to_i]['infrasubspecies'][0]
                    if nomenclator_ids[nomenclator_id.to_i]['kind'] == '0'
                      protonym.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalForm', subject_taxon_name: protonym, project_id: project_id)
                    elsif nomenclator_ids[nomenclator_id.to_i]['kind'] == '1'
                      protonym.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalVariety', subject_taxon_name: protonym, project_id: project_id)
                    elsif ['2', '3'].include?(nomenclator_ids[nomenclator_id.to_i]['kind'])
                      protonym.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalVariety', subject_taxon_name: protonym, project_id: project_id)
                      protonym.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::Excluded::Infrasubspecific')
                    end
                    protonym.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSubspecies', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['genus'][0] + '_' + nomenclator_ids[nomenclator_id.to_i]['subspecies'][0]]), project_id: project_id) if nomenclator_ids[nomenclator_id.to_i] && nomenclator_ids[nomenclator_id.to_i]['genus'] && nomenclator_ids[nomenclator_id.to_i]['subspecies']
                    if nomenclator_ids[nomenclator_id.to_i] && nomenclator_ids[nomenclator_id.to_i]['infrasubspecies'] && nomenclator_ids[nomenclator_id.to_i]['species'] && nomenclator_ids[nomenclator_id.to_i]['infrasubspecies'][0] == nomenclator_ids[nomenclator_id.to_i]['species'][0]
                      protonym.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSpecies', subject_taxon_name: protonym, project_id: project_id)
                    elsif nomenclator_ids[nomenclator_id.to_i] && nomenclator_ids[nomenclator_id.to_i]['genus'] && nomenclator_ids[nomenclator_id.to_i]['species']
                      protonym.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSpecies', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['genus'][0] + '_' + nomenclator_ids[nomenclator_id.to_i]['species'][0]]), project_id: project_id)
                    end
                    protonym.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['subgenus'][0]]), project_id: project_id) if nomenclator_ids[nomenclator_id.to_i] && nomenclator_ids[nomenclator_id.to_i]['subgenus']
                    protonym.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['genus'][0]]), project_id: project_id) if protonym.original_genus.nil? && nomenclator_ids[nomenclator_id.to_i] && nomenclator_ids[nomenclator_id.to_i]['genus'] && protonym.original_genus.nil?
                  end
                  missing_cites << [row['FileID'], row['TaxonNameID'], row['SeqNum'], "PROTONYM_SAVE_FAILED"] unless protonym.save
                  #string = [project_id, protonym.original_genus.try(:name), protonym.original_subgenus.try(:name), protonym.original_species.try(:name), protonym.original_subspecies.try(:name), protonym.original_variety.try(:name), protonym.original_form.try(:name)].compact.join('_')
                  tw_taxa_ids[project_id + '_' + nomenclator_string + '_' + protonym.cached_valid_taxon_name_id.to_s] = protonym.id if tw_taxa_ids[project_id + '_' + nomenclator_string + '_' + protonym.cached_valid_taxon_name_id.to_s].nil?
                  next
                elsif nomenclator_id == '0'
                  # no nomenclator data.
                elsif citation_on_otu || new_protonym
                                # just create another citation
                elsif tw_taxa_ids[project_id + '_' + nomenclator_string + '_' + protonym.cached_valid_taxon_name_id.to_s]
                  # just create another citation
                    taxon_name_id1 = tw_taxa_ids[project_id + '_' + nomenclator_string + '_' + protonym.cached_valid_taxon_name_id.to_s]

                    if !taxon_name_id1.nil?
                      p = TaxonName.find(taxon_name_id1)
                      if p && p.id != protonym.id
                        tr = TaxonNameRelationship::Iczn::Invalidating::Synonym.where(subject_taxon_name_id: protonym.id, object_taxon_name_id: p.id).first
                        if tr.nil? && nomenclator_is_synonym
                          p = p.valid_taxon_name if p.id != p.cached_valid_taxon_name_id && protonym.id != p.cached_valid_taxon_name_id && (p.name == p.valid_taxon_name.name || (!p.cached_secondary_homonym_alternative_spelling.nil? && p.cached_secondary_homonym_alternative_spelling == p.valid_taxon_name.cached_secondary_homonym_alternative_spelling))
                          tnc = protonym.taxon_name_classifications.create(type: 'TaxonNameClassification::Iczn::Available::Valid') if protonym.id == protonym.cached_valid_taxon_name_id
                          tr = TaxonNameRelationship.find_or_create_by(object_taxon_name_id: p.id, subject_taxon_name_id: protonym.id, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym', project_id: project_id)
                          skip_citation = true if tr.id
                        elsif protonym.cached_valid_taxon_name_id == p.cached_valid_taxon_name_id
                          protonym = p
                          taxon_name_id = p.id
                        end
                        if tr.try(:id)
                          citation = Citation.create(
                            citation_common_attributes.merge({
                              citation_object: tr
                            })
                          )
                          unless citation.id
                            missing_cites << [row['FileID'], row['TaxonNameID'], row['SeqNum'], "TR_CITATION_CREATE_FAILED"]

                            logger.error "TR_CITATION_CREATE_FAILED: FileID=#{row['FileID']}, TaxonNameID=#{row['TaxonNameID']}, SeqNum=#{row['SeqNum']}", citation.errors
                          end
                        end
                        skip_citation = true if tr.try(:id)
                      end
                  end
                elsif nomenclator_is_synonym && tw_taxa_ids[project_id + '_' + nomenclator_string]
                  taxon_name_id1 = tw_taxa_ids[project_id + '_' + nomenclator_string]
                  if !taxon_name_id1.nil?
                    p = TaxonName.find(taxon_name_id1)
                    tr = TaxonNameRelationship::Iczn::Invalidating::Synonym.where(subject_taxon_name_id: protonym.id, object_taxon_name_id: p.id).first
                    if tr.nil?
                      p = p.valid_taxon_name if p.id != p.cached_valid_taxon_name_id && protonym.id != p.cached_valid_taxon_name_id && (p.name == p.valid_taxon_name.name || (!p.cached_secondary_homonym_alternative_spelling.nil? && p.cached_secondary_homonym_alternative_spelling == p.valid_taxon_name.cached_secondary_homonym_alternative_spelling))
                      tnc = protonym.taxon_name_classifications.create(type: 'TaxonNameClassification::Iczn::Available::Valid') if protonym.id == protonym.cached_valid_taxon_name_id
                      tr = TaxonNameRelationship.find_or_create_by(object_taxon_name_id: p.id, subject_taxon_name_id: protonym.id, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym', project_id: project_id)
                    end
                    if tr.try(:id)
                      citation = Citation.create(
                        citation_common_attributes.merge({
                          citation_object: tr
                        })
                      )
                      missing_cites << [row['FileID'], row['TaxonNameID'], row['SeqNum'], "SYNONYM_TR_CITATION_CREATE_FAILED"] unless citation.id
                    end
                    skip_citation = true if tr.try(:id)
                  end
                else
                  p = Protonym.new(project_id: project_id) #, also_create_otu: true)
                  if rank_pass == 'genus'
                    next unless nomenclator_ids[nomenclator_id.to_i]['genus']
                    p.name = nomenclator_ids[nomenclator_id.to_i]['genus'][0]
                    p.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus', subject_taxon_name: p, project_id: p.id)
                  elsif rank_pass == 'subgenus'
                    next unless nomenclator_ids[nomenclator_id.to_i]['subgenus']
                    p.name = nomenclator_ids[nomenclator_id.to_i]['subgenus'][0]
                    p.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus', subject_taxon_name: p, project_id: p.id)
                    p.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['genus'][0]]), project_id: project_id) if nomenclator_ids[nomenclator_id.to_i] && nomenclator_ids[nomenclator_id.to_i]['genus']
                  elsif rank_pass == 'species'
                    next unless nomenclator_ids[nomenclator_id.to_i]['species']
                    p.name = nomenclator_ids[nomenclator_id.to_i]['species'][0]
                    p.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSpecies', subject_taxon_name: p, project_id: p.id)
                    p.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['subgenus'][0]]), project_id: project_id) if nomenclator_ids[nomenclator_id.to_i] && nomenclator_ids[nomenclator_id.to_i]['subgenus']
                    p.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['genus'][0]]), project_id: project_id) if nomenclator_ids[nomenclator_id.to_i] && nomenclator_ids[nomenclator_id.to_i]['genus']
                  elsif rank_pass == 'subspecies'
                    next unless nomenclator_ids[nomenclator_id.to_i]['subspecies']
                    p.name = nomenclator_ids[nomenclator_id.to_i]['subspecies'][0]
                    p.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSubspecies', subject_taxon_name: p, project_id: p.id)
                    if nomenclator_ids[nomenclator_id.to_i] && nomenclator_ids[nomenclator_id.to_i]['subspecies'] && nomenclator_ids[nomenclator_id.to_i]['species'] && nomenclator_ids[nomenclator_id.to_i]['subspecies'][0] == nomenclator_ids[nomenclator_id.to_i]['species'][0]
                      p.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSpecies', subject_taxon_name: p, project_id: p.id)
                    elsif nomenclator_ids[nomenclator_id.to_i] && nomenclator_ids[nomenclator_id.to_i]['genus'] && nomenclator_ids[nomenclator_id.to_i]['species']
                      p.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSpecies', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['genus'][0] + '_' + nomenclator_ids[nomenclator_id.to_i]['species'][0]]), project_id: project_id)
                    end
                    p.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['subgenus'][0]]), project_id: project_id) if nomenclator_ids[nomenclator_id.to_i] && nomenclator_ids[nomenclator_id.to_i]['subgenus']
                    p.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['genus'][0]]), project_id: project_id) if nomenclator_ids[nomenclator_id.to_i] && nomenclator_ids[nomenclator_id.to_i]['genus']
                  elsif rank_pass == 'infrasubspecies'
                    next unless nomenclator_ids[nomenclator_id.to_i]['infrasubspecies']
                    p.name = nomenclator_ids[nomenclator_id.to_i]['infrasubspecies'][0]
                    if nomenclator_ids[nomenclator_id.to_i]['kind'] == '0'
                      p.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalForm', subject_taxon_name: p, project_id: p.id)
                    elsif nomenclator_ids[nomenclator_id.to_i]['kind'] == '1'
                      p.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalVariety', subject_taxon_name: p, project_id: p.id)
                    elsif ['2', '3'].include?(nomenclator_ids[nomenclator_id.to_i]['kind'])
                      p.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalVariety', subject_taxon_name: p, project_id: p.id)
                      p.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::Excluded::Infrasubspecific')
                    end
                    p.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSubspecies', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['genus'][0] + '_' + nomenclator_ids[nomenclator_id.to_i]['subspecies'][0]]), project_id: project_id) if nomenclator_ids[nomenclator_id.to_i] && nomenclator_ids[nomenclator_id.to_i]['genus'] && nomenclator_ids[nomenclator_id.to_i]['subspecies']
                    if nomenclator_ids[nomenclator_id.to_i] && nomenclator_ids[nomenclator_id.to_i]['infrasubspecies'] && nomenclator_ids[nomenclator_id.to_i]['species'] && nomenclator_ids[nomenclator_id.to_i]['infrasubspecies'][0] == nomenclator_ids[nomenclator_id.to_i]['species'][0]
                      p.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSpecies', subject_taxon_name: p, project_id: p.id)
                    elsif nomenclator_ids[nomenclator_id.to_i] && nomenclator_ids[nomenclator_id.to_i]['genus'] && nomenclator_ids[nomenclator_id.to_i]['species']
                      p.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSpecies', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['genus'][0] + '_' + nomenclator_ids[nomenclator_id.to_i]['species'][0]]), project_id: project_id)
                    end
                    p.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['subgenus'][0]]), project_id: project_id) if nomenclator_ids[nomenclator_id.to_i] && nomenclator_ids[nomenclator_id.to_i]['subgenus']
                    p.related_taxon_name_relationships.new(type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus', subject_taxon_name: TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[nomenclator_id.to_i]['genus'][0]]), project_id: project_id) if protonym.original_genus.nil? && nomenclator_ids[nomenclator_id.to_i] && nomenclator_ids[nomenclator_id.to_i]['genus']
                  end
                  p.created_at = row['CreatedOn']
                  p.updated_at = row['LastUpdate']
                  p.created_by_id = get_tw_user_id[row['CreatedBy']]
                  p.updated_by_id = get_tw_user_id[row['ModifiedBy']]
                  p.parent_id = protonym.parent_id
                  p.rank_class = protonym.rank_class
                  p.save
                  if p.id.nil?
                    cites_id_done[row['TaxonNameID'].to_s + '_' + row['SeqNum'].to_s] = true
                    missing_cites << [row['FileID'], row['TaxonNameID'], row['SeqNum'], "PROTONYM_SAVE_FAILED_2"]
                    logger.error "PROTONYM_SAVE_FAILED_2: FileID=#{row['FileID']}, TaxonNameID=#{row['TaxonNameID']}, SeqNum=#{row['SeqNum']}", p.errors
                    next
                  end

                  tr = TaxonNameRelationship.create(subject_taxon_name: p, object_taxon_name: protonym, type: 'TaxonNameRelationship::Iczn::Invalidating', project_id: project_id)
                  byebug if tr.id.nil?
                  if nomenclator_is_synonym
                    protonym.taxon_name_classifications.create(type: 'TaxonNameClassification::Iczn::Available::Valid', project_id: project_id) if protonym.id == protonym.cached_valid_taxon_name_id
                    p1 = p
                    p1 = p.valid_taxon_name if p.id != p.cached_valid_taxon_name_id && protonym.id != p.cached_valid_taxon_name_id && (p.name == p.valid_taxon_name.name || (!p.cached_secondary_homonym_alternative_spelling.nil? && p.cached_secondary_homonym_alternative_spelling == p.valid_taxon_name.cached_secondary_homonym_alternative_spelling))

                    tr = TaxonNameRelationship::Iczn::Invalidating::Synonym.where(subject_taxon_name_id: protonym.id, object_taxon_name_id: p1.id).first

                    tr = TaxonNameRelationship.create(subject_taxon_name_id: protonym.id, object_taxon_name_id: p1.id, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym', project_id: project_id) if tr.nil?
                      if tr.nil? # Looks imposible to be false. Originally placed as if modifier of line below
                        citation = Citation.create(
                          citation_common_attributes.merge({
                            citation_object: tr
                          })
                        )
                        missing_cites << [row['FileID'], row['TaxonNameID'], row['SeqNum'], "SYNONYM_TR_CITATION_CREATE_FAILED_2"] unless citation.id
                      end
                    skip_citation = true if tr.try(:id)
                  end

                  byebug if tr.id.nil?
                  p.taxon_name_classifications.create(type: 'TaxonNameClassification::Iczn::Unavailable::NomenNudum', project_id: project_id) if row['NewNameStatusID'] == '6'
                  p.taxon_name_classifications.create(type: 'TaxonNameClassification::Iczn::Available::Valid::NomenDubium', project_id: project_id) if row['NewNameStatusID'] == '7'

                  cites_id_done[row['TaxonNameID'].to_s + '_' + row['SeqNum'].to_s] = true
                  protonym = p
                  taxon_name_id = p.id
                  tw_taxa_ids[project_id + '_' + nomenclator_string + '_' + protonym.cached_valid_taxon_name_id.to_s] = protonym.id if tw_taxa_ids[project_id + '_' + nomenclator_string + '_' + protonym.cached_valid_taxon_name_id.to_s].nil?
                end

                if !is_original && !skip_citation
                  if citation_on_otu
                    new_otu = Otu.find_or_create_by(
                                 taxon_name_id: protonym.id,
                                 name: citation_on_otu,
                                 project_id: project_id)
                    otu_id = new_otu.id
                  else
                    otu_id = get_taxon_name_otu_id[protonym.id.to_s].to_i
                  end
                  # byebug
                  if citation_on_otu || (protonym.is_genus_or_species_rank? && nomenclator_id == '0')
                    use_this_object_id = otu_id
                    this_object_type = 'Otu'
                  else
                    use_this_object_id = protonym.id
                    this_object_type = 'TaxonName'
                  end
                  citation = Citation.new(
                    citation_common_attributes.merge({
                      is_original: (row['SeqNum'] == '1' && protonym.source.nil? ? true : false),
                      citation_object_id: use_this_object_id,
                      citation_object_type: this_object_type
                    })
                  )

                  begin
                    citation.save!
                    if !qualifier_string.blank? && !citation.id.nil?
                      n = citation.notes.create(text: 'Cited as ' + qualifier_string, project_id: project_id, created_at: row['CreatedOn'], updated_at: row['LastUpdate'], created_by_id: get_tw_user_id[row['CreatedBy']], updated_by_id: get_tw_user_id[row['ModifiedBy']])
                    end
  #                  if nomenclator_is_synonym
  #                    syn_tnr = TaxonNameRelationship.where(object_taxon_name_id: taxon_name_id).with_type_base('TaxonNameRelationship::Iczn::Invalidating::Synonym')
  #                    if syn_tnr.count == 1
  #                      citation = Citation.create(
  #                          source_id: source_id,
  #                          pages: row['CitePages'],
  #                          citation_object: syn_tnr.first,
  #                          project_id: project_id,
  #                          created_at: row['CreatedOn'],
  #                          updated_at: row['LastUpdate'],
  #                          created_by_id: get_tw_user_id[row['CreatedBy']],
  #                          updated_by_id: get_tw_user_id[row['ModifiedBy']]
  #                      )
  #                    end
                    if !citation.id.nil?
                      citation.notes.create(text: row['Note'], project_id: project_id, created_at: row['CreatedOn'], updated_at: row['LastUpdate'], created_by_id: get_tw_user_id[row['CreatedBy']], updated_by_id: get_tw_user_id[row['ModifiedBy']])
                    end
                    unless citation.id.nil?
                      if nomenclator_id == '0' && protonym.is_genus_or_species_rank?
                        citation.tags.create(keyword_id: no_nomenclator_keywords[project_id])
                      end
                      unless new_name_cvt_id.blank?
                        #n = protonym.tags.find_or_create_by(keyword_id: new_name_cvt_id, project_id: project_id)
                        #n.citations.create!(source_id: citation.source_id, project_id: project_id)
                        citation.tags.create(keyword_id: new_name_cvt_id, project_id: project_id, created_at: row['CreatedOn'], updated_at: row['LastUpdate'], created_by_id: get_tw_user_id[row['CreatedBy']], updated_by_id: get_tw_user_id[row['ModifiedBy']])
                      end
                      unless type_info_cvt_id.blank?
                        #n = protonym.tags.find_or_create_by(keyword_id: type_info_cvt_id, project_id: project_id)
                        #n.citations.create!(source_id: citation.source_id, project_id: project_id)
                        citation.tags.create(keyword_id: type_info_cvt_id, project_id: project_id, created_at: row['CreatedOn'], updated_at: row['LastUpdate'], created_by_id: get_tw_user_id[row['CreatedBy']], updated_by_id: get_tw_user_id[row['ModifiedBy']])
                      end
                      unless info_flag_status_cvt_id.blank?
                        n = protonym.confidences.find_or_create_by(confidence_level_id: info_flag_status_cvt_id, project_id: project_id)
                        # byebug if n.nil? || n.id.nil?
                        n.citations.create(source_id: citation.source_id, project_id: project_id, created_at: row['CreatedOn'], updated_at: row['LastUpdate'], created_by_id: get_tw_user_id[row['CreatedBy']], updated_by_id: get_tw_user_id[row['ModifiedBy']])
                      end
                    end
                  rescue ActiveRecord::RecordInvalid # citation not valid


                    # yes I know this is ugly but it works
                    if citation.errors.messages[:source_id].nil?
                      logger.error "Citation ERROR [TW.project_id: #{project_id}, citation_object #{use_this_object_id}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{protonym.id}, otu_id #{otu_id}, SF.RefID #{row['RefID']} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']}] (#{error_counter += 1}): " + citation.errors.full_messages.join(';')
                      missing_cites << [row['FileID'], row['TaxonNameID'], row['SeqNum'], "CITATION_SAVE_FAILED"]
                      next
                    else # make pages unique and save again
                      if citation.errors.messages[:source_id].include?('has already been taken') # citation.errors.messages[:source_id][0] == 'has already been taken'
                        citation.pages = "#{row['CitePages']} [dupl #{row['SeqNum']}"
                        begin
                        #  citation.save # - looks ugly
                        missing_cites << [row['FileID'], row['TaxonNameID'], row['SeqNum'], "SOURCE_ALREADY_TAKEN"] # If line above gets uncommented this one must be commented
                        rescue ActiveRecord::RecordInvalid
                          # [ERROR]2018-03-30 17:09:43.127: Citation ERROR [TW.project_id: 11, SF.TaxonNameID 1152999 = TW.taxon_name_id 47338, SF.RefID 16047 = TW.source_id 12047, SF.SeqNum 2, nomenclator_string = Limnoperla jaffueli, name_status = 3] (total_error_counter = 1, source_used_counter = 1): Source has already been taken
                          logger.error "Citation ERROR [TW.project_id: #{project_id}, citation_object #{use_this_object_id}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{protonym.id}, otu_id #{otu_id}, SF.RefID #{row['RefID']} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']}, nomenclator_string = #{nomenclator_string}, name_status = #{row['NewNameStatusID']}], (current_error_counter = #{error_counter += 1}, source_used_counter = #{source_used_counter += 1}): " + citation.errors.full_messages.join(';')
                          logger.info "NewNameStatusID = #{row['NewNameStatusID']}, count = #{new_name_status[row['NewNameStatusID'].to_i] += 1}"
                          missing_cites << [row['FileID'], row['TaxonNameID'], row['SeqNum'], "DUPL_WORKAROUND_FAILED"]
                          next
                        end
                      else # citation error was not already been taken (other validation failure)
                        logger.error "Citation ERROR [TW.project_id: #{project_id}, citation_object #{use_this_object_id}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{protonym.id}, otu_id #{otu_id}, SF.RefID #{row['RefID']} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']}] (#{error_counter += 1}): " + citation.errors.full_messages.join(';')
                        missing_cites << [row['FileID'], row['TaxonNameID'], row['SeqNum'], "CITATION_NOT_VALID"]
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
  #                  logger.error "DataAttribute Nomenclator ERROR NomenclatorID = #{nomenclator_id}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{taxon_name_id} (error_counter = #{error_counter += 1}): " + da.errors.full_messages.join(';')
  #                end
  #              end

  ## ConceptChange: For now, do not import, only 2000 out of 31K were not automatically calculated, downstream in TW we will use Euler
  ## CurrentConcept: bit: For now, do not import
  # select * from tblCites c inner join tblTaxa t on c.TaxonNameID = t.TaxonNameID where c.CurrentConcept = 1 and t.NameStatus = 7
  # ## InfoFlags: Attribute/topic of citation?!! Treat like StatusFlags for individual values
  # # Use as topics on citations for OTUs, make duplicate citation on OTU, then topic on that citation

  #               info_flags = row['InfoFlags'].to_i
  #               if info_flags == 0
  #                 next
  #               end

  # # !! from here on we're back to referencing OTUs that were created PRE combination world

  #               # otu_id = get_taxon_name_otu_id[protonym.id.to_s].to_i  # previously set

  #               # if otu_id.blank?
  #               #   # lgo meessage
  #               #   otu_id = protonym.otus.first.try(:id) if otu_id.blank?
  #               # end
  #               #
  #               # if otu_id.blank?
  #               #   # !! a even more important log messages
  #               # end

  #               if otu_id.nil?
  #                 logger.warn "OTU error, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{protonym.id} (OTU not found: #{otu_not_found_counter += 1})"
  #                 next
  #               end

  #               base_cite_info_flags_uri = (base_uri + 'cite_info_flags/') # + bit_position below
  #               cite_info_flags_array = Utilities::Numbers.get_bits(info_flags)

  #               citation_topics_attributes = cite_info_flags_array.collect {|bit_position|
  #                 {topic_id: get_cvt_id[project_id][base_cite_info_flags_uri + bit_position.to_s],
  #                  project_id: project_id,
  #                  created_at: row['CreatedOn'],
  #                  updated_at: row['LastUpdate'],
  #                  created_by_id: get_tw_user_id[row['CreatedBy']],
  #                  updated_by_id: get_tw_user_id[row['ModifiedBy']]
  #                 }
  #               }

  #               otu_citation = Citation.new(
  #                 citation_common_attributes.merge({
  #                   source_id: source_id,
  #                   pages: row['CitePages'],
  #                   is_original: (row['SeqNum'] == '1' ? true : false),
  #                   citation_object_type: 'Otu',
  #                   citation_object_id: otu_id,
  #                   citation_topics_attributes: citation_topics_attributes,
  #                   notes_attributes: [text: JSON.pretty_generate(row.to_h.merge!({LOC: '10'}))]
  #                 })
  #               )

  #               begin
  #                 otu_citation.save!
  #                 puts 'OTU citation created'
  #               rescue ActiveRecord::RecordInvalid
  #                 logger.error "OTU citation ERROR SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{protonym.id} = otu_id #{otu_id} (error_counter = #{error_counter += 1}): " + otu_citation.errors.full_messages.join(';')
  #               end

                ## PolynomialStatus: based on NewNameStatus: Used to detect "fake" (previous combos) synonyms
                # Not included in initial import; after import, in TW, when we calculate CoL output derived from OTUs, and if CoL output is clearly wrong then revisit this issue
              end
            end # genus, subgenus, species, subspecies

            [cites_id_done, missing_cites, new_name_status]
          end.inject([{}, [], {}]) do |accum, vars|
            accum[0].merge!(vars[0])
            accum[1].concat(vars[1])

            vars[2].each do |key, value|
              accum[2][key] ||= 0
              accum[2][key] += value
            end

            accum
          end

          logger.info "Looking for citations not marked as done..."
          CSV.foreach(@args[:data_directory] + 'sfCites.txt', col_sep: "\t", headers: true, encoding: 'BOM|UTF-8') do |row|
            unless cites_id_done[row['TaxonNameID'].to_s + '_' + row['SeqNum'].to_s]
              logger.error "[#{row['FileID']}, #{row['TaxonNameID']}, #{row['SeqNum']}] not marked as done"
            end
          end

          logger.info "#{missing_cites.length} citations flagged as non-imported:\n" +
            "FileID\tTaxonNameID\tSeqNum\tReasonCode\t\n" +
            missing_cites.map { |c| c.join("\t") }.join("\n")

          # logger.info "total funny exceptions = '#{funny_exceptions_counter}', total unique_bad_nomenclators = '#{unique_bad_nomenclators.count}', \n unique_bad_nomenclators = '#{unique_bad_nomenclators}'"
          # ap "total funny exceptions = '#{funny_exceptions_counter}', total unique_bad_nomenclators = '#{unique_bad_nomenclators.count}', \n unique_bad_nomenclators = '#{unique_bad_nomenclators}'"
          logger.info 'new_name_status hash:', new_name_status
        end

        ################################################################################################# Nomenclator 2nd pass - Invalid to Combination
        desc 'time rake tw:project_import:sf_import:citations:create_combinations user_id=1 data_directory=/Users/proceps/src/sf/import/onedb2tw/working/'
        LoggedTask.define create_combinations: [:data_directory, :backup_directory, :environment, :user_id] do |logger|
          # proceps = User.where(email: 'arboridia@gmail.com').first
          #
          # Current.user_id = proceps.id
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
        end

        ################################################################################################# Nomenclator 3rd pass - Soft validation fixes
        desc 'time rake tw:project_import:sf_import:citations:soft_validation_fixes user_id=1 data_directory=/Users/proceps/src/sf/import/onedb2tw/working/'
        LoggedTask.define soft_validation_fixes: [:data_directory, :backup_directory, :environment, :user_id] do |logger|
          # proceps = User.where(email: 'arboridia@gmail.com').first

          # Current.user_id = proceps.id
          import = Import.find_or_create_by(name: 'SpeciesFileData')
          skipped_file_ids = import.get('SkippedFileIDs')
          get_tw_project_id = import.get('SFFileIDToTWProjectID')

          # Runs in parallel only if PARALLEL_PROCESSOR_COUNT is explicitely set (screen output is not very readable in parallel mode at present)
          output = Parallel.map(get_tw_project_id.values, in_processes: ENV['PARALLEL_PROCESSOR_COUNT'].to_i || 0) do |value|
            if skipped_file_ids.include? value.to_i
              next
            end
            print "\nSoft validations for the project #{value} \n"
            Current.project_id = value.to_i
            soft_validations_sf(value.to_i)
          end

          output.each do |output|
            output.each { |o| logger.info o } if output
          end
        end
        ######################################################################################################################################### END


        def invalid_relationship_remove_sf(project_id)

          GC.start
          fixed = 0
          combinations = 0
          i = 0
          Current.project_id = project_id

          j = 0
=begin
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
=end

          print "\nHandling Invalid relationships: synonyms to combinations. Project: #{project_id}\n"

          TaxonNameRelationship.where(project_id: project_id).with_type_string('TaxonNameRelationship::Iczn::Invalidating').pluck(:id).each do |t1|
            t = TaxonNameRelationship.find(t1)
            i += 1
            # next if i<10800
            print "\r#{i}    Fixes applied: #{fixed}    Combinations created: #{combinations}"
            if t.citations.empty?
              s = t.subject_taxon_name
              o = t.object_taxon_name
              shas = s.cached_secondary_homonym_alternative_spelling
              r = TaxonNameRelationship.where(project_id: project_id, object_taxon_name_id: s.id).with_type_base('TaxonNameRelationship::Iczn::Invalidating')
              r2 = TaxonNameRelationship.where(project_id: project_id, subject_taxon_name_id: s.id).with_type_base('TaxonNameRelationship::Iczn::Invalidating').count

              if s.taxon_name_classifications.empty? && r.empty?
                if o.rank_string =~ /Family/ && s.cached_primary_homonym_alternative_spelling == o.cached_primary_homonym_alternative_spelling && r2 == 1
                  t.type = 'TaxonNameRelationship::Iczn::Invalidating::Usage::FamilyGroupNameForm'
                  t.save
                  fixed += 1
                elsif o.rank_string =~ /Species/ && !s.original_combination_source.nil? && s.original_combination_source == o.original_combination_source && s.cached_primary_homonym_alternative_spelling == o.cached_primary_homonym_alternative_spelling && r2 == 1
                  if !s.original_subgenus.nil? && o.original_subgenus.nil?
                    o.original_subgenus = s.original_subgenus
                    fixed += 1
                  end
                  if !s.original_species.nil? && o.original_species.nil?
                    o.original_species = s.original_species
                    fixed += 1
                  end
                  if !s.original_subspecies.nil? && o.original_subspecies.nil?
                    o.original_subspecies = s.original_subspecies
                    fixed += 1
                  end
                  if !s.original_variety.nil? && o.original_variety.nil?
                    o.original_variety = s.original_variety
                    fixed += 1
                  end
                  if !s.original_form.nil? && o.original_form.nil?
                    o.original_form = s.original_form
                    fixed += 1
                  end
                  if !o.original_form.nil?
                    o.original_form = o
                  elsif !o.original_variety.nil?
                    o.original_variety = o
                  elsif !o.original_subspecies.nil?
                    o.original_subspecies = o
                  elsif !o.original_species.nil?
                    o.original_species = o
                  end
                  s.citations.each do |c|
                    c.citation_object_id = o.id
                    c.save
                  end
                  s.notes.each do |c|
                    c.note_object_id = o.id
                    c.save
                  end
                  s.tags.each do |c|
                    c.tag_object_id = o.id
                    c.save
                  end
                  s.data_attributes.each do |c|
                    c.attribute_subject_id = o.id
                    c.save
                  end
                  s.confidences.each do |c|
                    c.confidence_object_id = o.id
                    c.save
                  end

                  o.origin_citation.pages = s.origin_citation.pages if o.origin_citation.pages.blank?
                  o.data_attributes.create!(type: 'ImportAttribute', import_predicate: 'original name in SF', value: o.name)
                  old_name = o.name
                  o.name = s.name
                  o.taxon_name_classifications.new(type: 'TaxonNameClassification::Latinized::PartOfSpeech::Adjective')
                  t.destroy
                  s.destroy
                  o.save
                  gen = o.ancestor_at_rank('genus')
                  if o.masculine_name == old_name
                    gen.taxon_name_classifications.create(type: 'TaxonNameClassification::Latinized::Gender::Masculine') if gen
                  elsif o.feminine_name == old_name
                    gen.taxon_name_classifications.create(type: 'TaxonNameClassification::Latinized::Gender::Feminine') if gen
                  elsif o.neuter_name == old_name
                    gen.taxon_name_classifications.create(type: 'TaxonNameClassification::Latinized::Gender::Neuter') if gen
                  end
#                  t.type = 'TaxonNameRelationship::Iczn::Invalidating::Usage::IncorrectOriginalSpelling'
#                  t.save
#                  fixed += 1
                elsif (o.rank_string =~ /Species/ && shas == o.cached_secondary_homonym_alternative_spelling && r2 == 1) || (o.rank_string =~ /Genus/ && s.cached_primary_homonym_alternative_spelling == o.cached_primary_homonym_alternative_spelling && r2 == 1)
                  s = s.becomes_combination
                  combinations += 1 if s.type == 'Combination'
                end
              end
            end
          end
        end

        def soft_validations_sf(project_id)
          output = []
          fixed = 0
          print "\nApply soft validation fixes to taxa 1st pass \n"
          i = 0
          GC.start
          TaxonName.where(project_id: project_id).find_each do |t|
            i += 1
            print "\r#{i}    Fixes applied: #{fixed}"
            t.soft_validate(fixable: true)
            t.fix_soft_validations
            t.soft_validations.soft_validations.each do |f|
              fixed += 1 if f.fixed?
            end
          end

          output.push "[project_id=#{project_id}] Soft validation fixes to taxa 1st pass: #{i} names, #{fixed} fixes applied"

          print "\nApply soft validation fixes to relationships \n"
          i = 0
          GC.start
          TaxonNameRelationship.where(project_id: project_id).find_each do |t|
            i += 1
            print "\r#{i}    Fixes applied: #{fixed}"
            t.soft_validate(fixable: true, except_sets: [:coordinated_taxa])
            t.fix_soft_validations
            t.soft_validations.soft_validations.each do |f|
              fixed += 1 if f.fixed?
            end
          end

          output.push "[project_id=#{project_id}] Soft validation fixes to relationships: #{i} relationships, #{fixed} fixes applied (including previous step)"

          print "\nApply soft validation fixes to taxa 2nd pass \n"
          i = 0
          GC.start
          TaxonName.where(project_id: project_id).find_each do |t|
            i += 1
            print "\r#{i}    Fixes applied: #{fixed}"
            t.soft_validate(fixable: true)
            t.fix_soft_validations
            t.soft_validations.soft_validations.each do |f|
              fixed += 1 if f.fixed?
            end
          end

          output.push "[project_id=#{project_id}] Soft validation fixes to taxa 2nd pass: #{i} names, #{fixed} fixes applied (including previous steps)"
          output
        end

      end
    end
  end
end

