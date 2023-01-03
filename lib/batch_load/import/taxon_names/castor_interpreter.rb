module BatchLoad
  class Import::TaxonNames::CastorInterpreter < BatchLoad::Import

    # The parent for the top level names
    attr_accessor :parent_taxon_name

    # The id of the parent taxon name, computed automatically as Root if not provided
    attr_accessor :parent_taxon_name_id

    # The default parent if otherwise not provided
    attr_accessor :base_taxon_name_id

    # The code (Rank Class) that new names will use
    attr_accessor :nomenclature_code

    # @return Boolean
    # Whether to create an OTU as well
    attr_accessor :also_create_otu

    # Required to handle some defaults
    attr_accessor :project_id

    SAVE_ORDER = [:original_taxon_name, :taxon_name, :taxon_name_relationship, :otu]

    # @param [Hash] args
    def initialize(nomenclature_code: nil, parent_taxon_name_id: nil, also_create_otu: false, **args)
      @nomenclature_code = nomenclature_code
      @parent_taxon_name_id = parent_taxon_name_id
      @also_create_otu = also_create_otu

      super(**args)
    end

    def also_create_otu
      return true if [1, '1', true].include?(@also_create_otu)
      false
    end

    # @return [String]
    def parent_taxon_name
      Project.find(@project_id).root_taxon_name
    end

    # @return [Integer]
    def parent_taxon_name_id
      parent_taxon_name.id
    end

    # rubocop:disable Metrics/MethodLength
    # @return [Integer]
    def build_taxon_names
      @total_data_lines = 0
      i = 0
      taxon_names = {}

      csv.each do |row|
        i += 1

        parse_result = BatchLoad::RowParse.new
        parse_result.objects[:original_taxon_name] = []
        parse_result.objects[:taxon_name] = []
        parse_result.objects[:taxon_name_relationship] = []
        parse_result.objects[:otu] = []

        @processed_rows[i] = parse_result

        begin
          next if ['complex', 'species group', 'series', 'variety', 'unidentified'].include?(row['rank'])

          protonym_attributes = {
            name: row['taxon_name'],
            year_of_publication: year_of_publication(row['author_year']),
            rank_class: Ranks.lookup(@nomenclature_code.to_sym, row['rank']),
            by: user,
            project: project,
            verbatim_author: verbatim_author(row['author_year']),
            taxon_name_authors_attributes: taxon_name_authors_attributes(verbatim_author(row['author_year']))
          }

          if row['original_name']
            original_protonym_attributes = {
              verbatim_name: row['original_name'],
              name: row['original_name'].split(' ')[-1],
              year_of_publication: year_of_publication(row['author_year']),
              rank_class: Ranks.lookup(@nomenclature_code.to_sym, row['original_rank']),
              parent: parent_taxon_name,
              by: user,
              project: project,
              verbatim_author: verbatim_author(row['author_year']),
              taxon_name_authors_attributes: taxon_name_authors_attributes(verbatim_author(row['author_year']))
            }

            original_protonym = Protonym.new(original_protonym_attributes)

            if row['original_rank'] == 'genus'
              protonym_attributes[:original_genus] = original_protonym
            elsif row['original_rank'] == 'subgenus'
              protonym_attributes[:original_subgenus] = original_protonym
            elsif row['original_rank'] == 'species'
              protonym_attributes[:original_species] = original_protonym
            elsif row['original_rank'] == 'subspecies'
              protonym_attributes[:original_subspecies] = original_protonym
            end

            parse_result.objects[:original_taxon_name].push original_protonym
          end

          p = Protonym.new(protonym_attributes)
          taxon_name_id = row['id']
          parent_taxon_name_id = row['parent_id']
          taxon_names[taxon_name_id] = p

          if taxon_names[parent_taxon_name_id].nil?
            p.parent = parent_taxon_name
          else
            p.parent = taxon_names[parent_taxon_name_id]
          end

          # TaxonNameRelationship
          related_name_id = row['related_name_id']
          
          if !taxon_names[related_name_id].blank?
            related_name_nomen_class = nil

            begin
              related_name_nomen_class = row['related_name_nomen_class'].safe_constantize

              if related_name_nomen_class.ancestors.include?(TaxonNameRelationship)
                
                taxon_name_relationship = related_name_nomen_class.new(
                  subject_taxon_name: p, object_taxon_name: taxon_names[related_name_id]
                )
                parse_result.objects[:taxon_name_relationship].push taxon_name_relationship
              end
            rescue NameError
            end
          end

          # TaxonNameClassification

          # TODO: add to index, not here
          if name_nomen_classification = row['name_nomen_classification']
            if c = name_nomen_classification.safe_constantize
              # if EXCEPTED_FORM_TAXON_NAME_CLASSIFICATIONS.include?(name_nomen_classification)
              p.taxon_name_classifications_attributes = [ {type: name_nomen_classification} ]
            end
          end

          # There is an OTU linked to the taxon name
          if !row['taxon_concept_name'].blank? || !row['guid'].blank?
            taxon_concept_identifier_castor = {}

            if !row['guid'].blank?
              taxon_concept_identifier_castor = {
                type: 'Identifier::Global::Uri',
                identifier: row['guid'] }
            end

            otu = Otu.new(name: row['taxon_concept_name'], taxon_name: p, identifiers_attributes: [taxon_concept_identifier_castor] )

            parse_result.objects[:otu].push(otu)
          else
            # Note we are not technically using the param like TaxonName.new(), so we can't just set the attribute
            # So we hack in the OTUs 'manually".  This also lets us see them in the result
            if also_create_otu 
              parse_result.objects[:otu].push( Otu.new(taxon_name: p) )
            end
          end

          parse_result.objects[:taxon_name].push p
          @total_data_lines += 1 if p.present?
        end
      end

      @total_lines = i
    end
    # rubocop:enable Metrics/MethodLength

    # @return [Boolean]
    def build
      if valid?
        build_taxon_names
        @processed = true
      end
    end

    private

    # @param [String] author_year
    # @return [String, nil]
    def year_of_publication(author_year)
      return nil if author_year.blank?
      split_author_year = author_year.split(' ')
      year = split_author_year[split_author_year.length - 1]
      year =~ /\A\d+\z/ ? year : ''
    end

    # @param [String] author_year
    # @return [String, nil] just the author name, wiht parens left on
    def verbatim_author(author_year)
      return nil if author_year.blank?
      author_year.gsub(/\,+\s*\d\d\d\d/, '')
    end

    # @param [String] author_info
    # @return [Array]
    def taxon_name_authors_attributes(author_info)
      return [] if author_info.blank?
      multiple_author_query = 'and'
      multiple_author_index = author_info.index(multiple_author_query)
      split_author_info = multiple_author_index.nil? ? [author_info] : author_info.split(multiple_author_query)
      author_infos = []

      split_author_info.each do |author_str|
        author_infos.push(author_info(author_str)) if author_str != 'NA' && author_str != 'unpublished'
      end

      author_infos
    end

    # @param [String] author_string
    # @return [Hash]
    def author_info(author_string)
      seperator_query = ' '
      separator_index = author_string.index(seperator_query)

      last_name = author_string
      first_name = ''

      if !separator_index.nil?
        separator_index += seperator_query.length
        split_author_info = author_string.split(seperator_query)
        last_name = split_author_info[0]
        first_name = split_author_info[1]
      end

      { last_name: last_name, first_name: first_name, suffix: 'suffix' }
    end
  end
end
