namespace :tw do
  namespace :project_import do
    namespace :sf_import do
      require 'fileutils'
      require 'logged_task'
      namespace :pre_cites do

        desc 'time rake tw:project_import:sf_import:pre_cites:check_original_genus_ids user_id=1 data_directory=/Users~/src/onedb2tw/working/'
        LoggedTask.define check_original_genus_ids: [:data_directory, :backup_directory, :environment, :user_id] do |logger|
          # Though TW species groups, etc. have an original genus, SF ones do not: Do not infer it at this time

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          skipped_file_ids = import.get('SkippedFileIDs')
          excluded_taxa = import.get('ExcludedTaxa')
          get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping
          get_tw_project_id = import.get('SFFileIDToTWProjectID')
          get_tw_taxon_name_id = import.get('SFTaxonNameIDToTWTaxonNameID') # key = SF.TaxonNameID, value = TW.taxon_name.id

          count_found = 0
          not_found = 0

          nomenclator_id_lut = {}
          nomenclator_is_species_lut = {}


          CSV.foreach(@args[:data_directory] + 'tblCites.txt', col_sep: "\t", headers: true, encoding: 'BOM|UTF-8') do |row|
            nomenclator_id_lut[[row["TaxonNameID"], row["RefID"]]] = row["NomenclatorID"]
          end

          CSV.foreach(@args[:data_directory] + 'tblNomenclator.txt', col_sep: "\t", headers: true, encoding: 'BOM|UTF-8') do |row|
            nomenclator_is_species_lut[row["NomenclatorID"]] =
              row["SpeciesNameID"].to_i != 0 &&
              row["SubspeciesNameID"].to_i == 0 &&
              row["InfrasubspeciesNameID"].to_i == 0
          end

          path = @args[:data_directory] + 'sfTaxaByTaxonNameStr.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each_with_index do |row, i|
            taxon_name_id = row['TaxonNameID']
            next if skipped_file_ids.include? row['FileID'].to_i
            next if excluded_taxa.include? taxon_name_id
            next unless row['RankID'].to_i < 11 # only look at species and subspecies
            next if row['OriginalGenusID'] == '0'

            species_id = get_tw_taxon_name_id[taxon_name_id]
            next unless species_id

            # Maybe ignore or use only when cannot be extracted from nomenclator of original citation
            if get_tw_taxon_name_id[row['OriginalGenusID']]
              original_genus_id = get_tw_taxon_name_id[row['OriginalGenusID']]
            else
              logger.error "TW Original Genus not found: SF.OriginalGenusID = #{row['OriginalGenusID']}, SF.FileID = #{row['FileID']} (not_found #{not_found += 1}) \n"
              next
            end

            logger.info "Working with SF.TaxonNameID = #{taxon_name_id}, TW.taxon_name_id = #{species_id}, SF.OriginalGenusID = #{row['OriginalGenusID']}, TW.original_genus_id = #{original_genus_id} (count #{count_found += 1}) \n"

            species_protonym = Protonym.find(species_id)
            if species_protonym.original_genus.nil?
              # species_protonym.update(original_genus: )
              TaxonNameRelationship::OriginalCombination::OriginalGenus.find_or_create_by!(
                  subject_taxon_name_id: original_genus_id,
                  object_taxon_name_id: species_id,
                  created_by_id: get_tw_user_id[row['CreatedBy']],
                  updated_by_id: get_tw_user_id[row['ModifiedBy']],
                  project_id: get_tw_project_id[row['FileID']])
            end

            if species_protonym.rank_class.rank_name =~ /Subspecies/i # Handle some [SPECIES NOT SPECIFIED] cases
              if species_protonym.original_species.nil? && nomenclator_is_species_lut[ nomenclator_id_lut[ [row["TaxonNameID"], row["RefID"]] ] ]
                TaxonNameRelationship::OriginalCombination::OriginalSpecies.find_or_create_by!(
                  subject_taxon_name_id: species_id,
                  object_taxon_name_id: species_id,
                  created_by_id: get_tw_user_id[row['CreatedBy']],
                  updated_by_id: get_tw_user_id[row['ModifiedBy']],
                  project_id: get_tw_project_id[row['FileID']])
              end
            end
          end
        end

        desc 'time rake tw:project_import:sf_import:pre_cites:create_cvts_for_citations user_id=1 data_directory=~/src/onedb2tw/working/'
        LoggedTask.define create_cvts_for_citations: [:data_directory, :backup_directory, :environment, :user_id] do |logger|

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

              # info_flag_status used to be type = 'ConfidenceLevel'; now citations cannot have confidences, so changed to keyword
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

        desc 'time rake tw:project_import:sf_import:pre_cites:import_nomenclator_metadata user_id=1 data_directory=~/src/onedb2tw/working/'
        LoggedTask.define import_nomenclator_strings: [:data_directory, :backup_directory, :environment, :user_id] do |logger|
          # Can be run independently at any time

          logger.info 'Running import_nomenclator_metadata...'

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          skipped_file_ids = import.get('SkippedFileIDs')

          get_nomenclator_metadata = {} # key = SF.NomenclatorID, value = hash of nomenclator_string, ident_qualifier, file_id

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


