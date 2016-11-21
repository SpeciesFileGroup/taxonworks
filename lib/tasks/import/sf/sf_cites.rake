namespace :tw do
  namespace :project_import do
    namespace :sf_import do
      require 'fileutils'
      require 'logged_task'
      namespace :cites do

        desc 'time rake tw:project_import:sf_import:cites:create_citations user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :create_some_related_taxa => [:data_directory, :environment, :user_id] do |logger|

          logger.info 'Creating citations...'
          # Probably have original description from taxon import: how to handle duplicate?
          # Create note for tblCites.Note
          # Create data_attributes for NomenclatorID becomes nomenclator_string
          # Create topics for:
          #   NewNameStatusID
          #   TypeInfoID
          #   ConceptChangeID
          #   CurrentConcept
          #   InfoFlags
          #   InfoFlagStatus
          #   PolynomialStatus


          import = Import.find_or_create_by(name: 'SpeciesFileData')
          get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping
          get_tw_taxon_name_id = import.get('SFTaxonNameIDToTWTaxonNameID')
          # get_tw_otu_id = import.get('SFTaxonNameIDToTWOtuID')
          get_tw_source_id = import.get('SFRefIDToTWSourceID')
          get_nomenclator_string = import.get('SFNomenclatorIDToSFNomenclatorString')

          # @todo: Temporary "fix" to convert all values to string; will be fixed next time taxon names are imported and following do can be deleted
          get_tw_taxon_name_id.each do |key, value|
            get_tw_taxon_name_id[key] = value.to_s
          end

          # set up topics

          path = @args[:data_directory] + 'tblCites.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

          count_found = 0
          error_counter = 0

          file.each_with_index do |row, i|
            taxon_name_id = get_tw_taxon_name_id[row['TaxonNameID']].to_i
            next unless TaxonName.where(id: taxon_name_id).any?

            project_id = TaxonName.find(taxon_name_id).project_id.to_i
            source_id = get_tw_source_id[row['RefID']].to_i
            logger.info "Working with TW.project_id: #{project_id}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{taxon_name_id},
SF.RefID #{row['RefID']} = TW.source_id #{row['']}, SF.SeqNum #{row['SeqNum']} (count #{count_found += 1}) \n"

            # @todo Original description citation most likely exists already but pages are source pages, not cite pages

            # is origin?
            # match source_id, cit_type, cit_obj_id

            # if citation = Citation.where(source_id: <>, is_origin: true, ...).first
            # citation.notes << Note.new(text: row['Note']) unless row['Note'].blank?
            # citation.update_column(:pages, row['Pages'])
            #
            # else
            #  citation = Citation.new()
            #
            #
            #

            cite_pages = row['CitePages']

            # Basic citation can now be created:
            citation = Citation.new(
                source_id: source_id,
                pages: cite_pages,
                # is_original:
                citation_object_type: 'TaxonName',
                citation_object_id: taxon_name_id,

                ## Note: Add as attribute before save citation
                notes_attributes: [{text: (row['Note'].blank? ? nil : row['Note']),
                                    project_id: project_id,
                                    created_at: row['CreatedOn'],
                                    updated_at: row['LastUpdate'],
                                    created_by_id: get_tw_user_id[row['CreatedBy']],
                                    updated_by_id: get_tw_user_id[row['ModifiedBy']]}],

                # housekeeping for citation
                project_id: project_id,
                created_at: row['CreatedOn'],
                updated_at: row['LastUpdate'],
                created_by_id: get_tw_user_id[row['CreatedBy']],
                updated_by_id: get_tw_user_id[row['ModifiedBy']]
            )

            begin
              citation.save!
              logger.info "Citation saved"
            rescue ActiveRecord::RecordInvalid # citation not valid
              logger.info "Citation ERROR (#{error_counter += 1}): " + citation.errors.full_messages.join(';')
              next
            end

            ### After citation created

            ## Nomenclator: DataAttribute of citation, NomenclatorID > 0
            if row['NomenclatorID'] != '0' # OR could value: be evaluated below based on NomenclatorID?
              da = DataAttribute.new(type: 'ImportAttribute',
                                     attribute_subject_id: citation.id,
                                     attribute_subject_type: 'Citation',
                                     import_predicate: 'Nomenclator',
                                     value: get_nomenclator_string[row['NomenclatorID']],
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
                logger.error "DataAttribute Nomenclator ERROR NomenclatorID = #{row['NomenclatorID']}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{taxon_name_id} (#{error_counter += 1}): " + da.errors.full_messages.join(';')
              end
            end


            ## NewNameStatus: As tags to citations, create 16 keywords for each project, set up in case statement


            ## TypeInfo: As tags to citations, create n keywords for each project, set up in case statement (2364 cases!)


            ## ConceptChange: For now, do not import, only 2000 out of 31K were not automatically calculated, downstream in TW we will use Euler

            ## CurrentConcept: bit: For now, do not import
            # select * from tblCites c inner join tblTaxa t on c.TaxonNameID = t.TaxonNameID where c.CurrentConcept = 1 and t.NameStatus = 7


            ## InfoFlags: Attribute/topic of citation?!! Treat like StatusFlags for individual values
            # use as topics on citations for OTUs, make duplicate citation on OTU, then topic on that citation

            info_flags = row['InfoFlags'].to_i

            if info_flags > 0
              cite_info_flags_array = Utilities::Numbers.get_bits(info_flags)

              cite_info_flags_array.each do |bit_position|

                # no_relationship = false # set to true if no relationship should be created
                # bit_flag_name = ''

                case bit_position

                  when 1 # Image or description
                  when 2 # Phylogeny or classification
                  when 3 # Ecological data
                  when 4 # Specimen or distribution
                  when 5 # Key
                  when 6 # Life history
                  when 7 # Behavior
                  when 8 # Economic matters
                  when 9 # Physiology
                  when 10 # Structure
                end
              end
            end


            ## InfoFlagStatus: Add confidence, 1 = partial data or needs review, 2 = complete data
            # @!attribute confidence_level_id
            #   @return [Integer]
            #     the controlled vocabulary term used in the confidence
            #
            # @!attribute confidence_object_id
            #   @return [Integer]
            #      Rails polymorphic. The id of of the object being annotated.
            #
            # @!attribute confidence_object_type
            #   @return [String]
            #      Rails polymorphic.  The type of the object being annotated.
            #
            # @!attribute project_id
            #   @return [Integer]
            #   the project ID
            #
            # @!attribute position
            #   @return [Integer]
            #     a user definable sort code on the tags on an object, handled by acts_as_list

            # [11/18/16, 4:10:27 PM] Marilyn Beckman: For confidences, do I first create a ConfidenceLevel which defines the item about which I am confident?
            # [11/18/16, 4:10:56 PM] Marilyn Beckman: Then I assign a specific confidence for a given datum??

            info_flag_status = row['InfoFlagStatus'].to_i

            # if info_flag_status > 0
            #   confidence = Confidence.new(
            #                              confidence_level_id: row['InfoFlagStatus'],
            #
            #   )
            # end


            ## PolynomialStatus: based on NewNameStatus: Used to detect "fake" (previous combos) synonyms
            # Not included in initial import; after import, in TW, when we calculate CoL output derived from OTUs, and if CoL output is clearly wrong then revisit this issue


          end
        end


        desc 'time rake tw:project_import:sf_import:cites:create_topics_for_citations user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        # @todo Do I really need a data_directory if I'm using a Postgres table? Not that it hurts...
        LoggedTask.define :create_topics_for_citations => [:data_directory, :environment, :user_id] do |logger|

          # Create topics for each project consisting of:
          #   NewNameStatusID
          #   TypeInfoID
          #   ConceptChangeID
          #   CurrentConcept
          #   InfoFlags
          #   InfoFlagStatus
          #   PolynomialStatus

          cites_cvts = [

            new_name_status: [
                {name: 'unchanged', definition: 'Status of name did not change', uri: 'http://speciesfile.org/legacy/new_name_status/1', type: 'Keyword'},
                {name: 'new name', definition: 'New name, unneeded emendation or subsequent mispelling', uri: 'http://speciesfile.org/legacy/new_name_status/2', type: 'Keyword'},
                {name: 'made synonym', definition: 'Status of name changed to synonym', uri: 'http://speciesfile.org/legacy/new_name_status/3', type: 'Keyword'},
                {name: 'made valid or temporary', definition: 'Name treated as valid or temporary', uri: 'http://speciesfile.org/legacy/new_name_status/4', type: 'Keyword'},
                {name: 'new combination', definition: 'Remains valid in new combination', uri: 'http://speciesfile.org/legacy/new_name_status/5', type: 'Keyword'},
                {name: 'new nomen nudum', definition: 'Name is a new nomen nudum', uri: 'http://speciesfile.org/legacy/new_name_status/6', type: 'Keyword'},
                {name: 'nomen dubium', definition: 'Name treated as nomen dubium', uri: 'http://speciesfile.org/legacy/new_name_status/7', type: 'Keyword'},
                {name: 'missed previous change', definition: 'Apparently missed a previous change', uri: 'http://speciesfile.org/legacy/new_name_status/8', type: 'Keyword'},
                {name: 'still synonym, but of different taxon', definition: 'Name remains a synonym , but of different taxon', uri: 'http://speciesfile.org/legacy/new_name_status/9', type: 'Keyword'},
                {name: 'gender change', definition: 'Name changed to match gender of genus', uri: 'http://speciesfile.org/legacy/new_name_status/10', type: 'Keyword'},
                {name: 'new corrected name', definition: 'Justified emendation, corrected lapsus, or nomen nudum made available', uri: 'http://speciesfile.org/legacy/new_name_status/17', type: 'Keyword'},
                {name: 'different combination', definition: 'Remains valid in restored combination', uri: 'http://speciesfile.org/legacy/new_name_status/18', type: 'Keyword'},
                {name: 'made valid in new combination', definition: 'Made valid in new or different combination', uri: 'http://speciesfile.org/legacy/new_name_status/19', type: 'Keyword'},
                {name: 'incorrect name before correct', definition: 'Nomen nudum, incorrect spelling or lapsus before proper name', uri: 'http://speciesfile.org/legacy/new_name_status/20', type: 'Keyword'},
                {name: 'misapplied name', definition: 'Misapplied name used for misidentified specimen', uri: 'http://speciesfile.org/legacy/new_name_status/22', type: 'Keyword'},
             ],

            type_info: [
                {name: 'unspecified type information', definition: 'unspecified type information', uri: 'http://speciesfile.org/legacy/type_info/1', type: 'Keyword'},
                {name: 'ruling by Commission', definition: 'ruling by Commission', uri: 'http://speciesfile.org/legacy/type_info/2', type: 'Keyword'},
                {name: 'designated syntypes', definition: 'designated syntypes', uri: 'http://speciesfile.org/legacy/type_info/11', type: 'Keyword'},
                {name: 'designated holotype', definition: 'designated holotype', uri: 'http://speciesfile.org/legacy/type_info/12', type: 'Keyword'},
                {name: 'designated lectotype', definition: 'designated lectotype', uri: 'http://speciesfile.org/legacy/type_info/13', type: 'Keyword'},
                {name: 'designated neotype', definition: 'designated neotype', uri: 'http://speciesfile.org/legacy/type_info/14', type: 'Keyword'},
                {name: 'removed syntype(s)', definition: 'removed syntype(s)', uri: 'http://speciesfile.org/legacy/type_info/15', type: 'Keyword'},
                {name: 'original monotypy', definition: 'original monotypy', uri: 'http://speciesfile.org/legacy/type_info/21', type: 'Keyword'},
                {name: 'original designation', definition: 'original designation', uri: 'http://speciesfile.org/legacy/type_info/22', type: 'Keyword'},
                {name: 'subsequent designation', definition: 'subsequent designation', uri: 'http://speciesfile.org/legacy/type_info/23', type: 'Keyword'},
                {name: 'monotypy and original designation', definition: 'monotypy and original designation', uri: 'http://speciesfile.org/legacy/type_info/24', type: 'Keyword'},
                {name: 'removed potential type(s)', definition: 'removed potential type(s)', uri: 'http://speciesfile.org/legacy/type_info/25', type: 'Keyword'},
                {name: 'absolute tautonomy', definition: 'absolute tautonomy', uri: 'http://speciesfile.org/legacy/type_info/26', type: 'Keyword'},
                {name: 'Linnaean tautonomy', definition: 'Linnaean tautonomy', uri: 'http://speciesfile.org/legacy/type_info/27', type: 'Keyword'},
                {name: 'inherited from replaced name', definition: 'inherited from replaced name', uri: 'http://speciesfile.org/legacy/type_info/29', type: 'Keyword'},
             ],

            # uri end number represents bit position, not value
            cite_info_flags: [
                {name: 'Image or description', definition: 'An image or description is included', uri: 'http://speciesfile.org/legacy/cite_info_flags/0', type: 'Topic'},
                {name: 'Phylogeny or classification', definition: 'An evolutionary relationship or hierarchical position is presented or discussed', uri: 'http://speciesfile.org/legacy/cite_info_flags/1', type: 'Topic'},
                {name: 'Ecological data', definition: 'Ecological data are included', uri: 'http://speciesfile.org/legacy/cite_info_flags/2', type: 'Topic'},
                {name: 'Specimen or distribution', definition: 'Specimen or distribution information is included', uri: 'http://speciesfile.org/legacy/cite_info_flags/3', type: 'Topic'},
                {name: 'Key', definition: 'A key for identification is included', uri: 'http://speciesfile.org/legacy/cite_info_flags/4', type: 'Topic'},
                {name: 'Life history', definition: 'Life history information is included', uri: 'http://speciesfile.org/legacy/cite_info_flags/5', type: 'Topic'},
                {name: 'Behavior', definition: 'Behavior information is included', uri: 'http://speciesfile.org/legacy/cite_info_flags/6', type: 'Topic'},
                {name: 'Economic matters', definition: 'Economic matters are included', uri: 'http://speciesfile.org/legacy/cite_info_flags/7', type: 'Topic'},
                {name: 'Physiology', definition: 'Physiology is included', uri: 'http://speciesfile.org/legacy/cite_info_flags/8', type: 'Topic'},
                {name: 'Structure', definition: 'Anatomy, cytology, genetic or other structural information is included', uri: 'http://speciesfile.org/legacy/cite_info_flags/9', type: 'Topic'},
             ],

          ]



          ## NewNameStatus: As tags to citations, create 16 keywords for each project, set up in case statement


          ## TypeInfo: As tags to citations, create n keywords for each project, set up in case statement (2364 cases!)


          ## InfoFlags: Attribute/topic of citation?!! Treat like StatusFlags for individual values
          # use as topics on citations for OTUs, make duplicate citation on OTU, then topic on that citation

          logger.info 'Running create_topics...'

          names = {} # initialize names hash

          Project.all.each do |project|
            next unless project.name.end_with?('species_file')

            names[project.id.to_s] = project.name # don't really need hash, but conveys logger info
            project_id = project.id

            logger.info "Working with TW.project_id: #{project_id} = '#{project.name}'"

            CITES_CVTS.keys.each do |k|
              CITES_CVTS[k].each do |id, params|
                 ControlledVocabularyTerm.create!(params)
              end
            end

            Topic.create!(
                name: 'NewNameStatus',
                definition: 'something'
            )


          end
        end

        desc 'time rake tw:project_import:sf_import:cites:import_nomenclator_strings user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :import_nomenclator_strings => [:data_directory, :environment, :user_id] do |logger|
          # Can be run independently at any time

          logger.info 'Running import_nomenclator_strings...'

          get_nomenclator_string = {} # key = SF.NomenclatorID, value = SF.nomenclator_string

          count_found = 0

          path = @args[:data_directory] + 'sfNomenclatorStrings.txt'
          file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each_with_index do |row, i|
            nomenclator_id = row['NomenclatorID']
            next if nomenclator_id == '0'

            nomenclator_string = row['NomenclatorString']

            logger.info "Working with SF.NomenclatorID '#{nomenclator_id}', SF.NomenclatorString '#{nomenclator_string}' (count #{count_found += 1}) \n"

            get_nomenclator_string[nomenclator_id] = nomenclator_string
          end

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          import.set('SFNomenclatorIDToSFNomenclatorString', get_nomenclator_string)

          puts = 'SFNomenclatorIDToSFNomenclatorString'
          ap get_nomenclator_string
        end

      end
    end
  end
end
