# TODO: THIS IS A GENERATED STUB, it does not function
module BatchLoad
  class Import::TaxonNames::CastorInterpreter < BatchLoad::Import

    # The parent for the top level names
    attr_accessor :parent_taxon_name

    # The id of the parent taxon name, computed automatically as Root if not provided
    attr_accessor :parent_taxon_name_id

    # The code (Rank Class) that new names will use
    attr_accessor :nomenclature_code

    # Whether to create an OTU as well
    attr_accessor :also_create_otu

    # Required to handle some defaults
    attr_accessor :project_id

    def initialize(nomenclature_code: nil, parent_taxon_name_id: nil, also_create_otu: false, **args)
      @nomenclature_code = nomenclature_code
      @parent_taxon_name_id = parent_taxon_name_id
      @also_create_otu = also_create_otu

      super(args)
    end
    
    def parent_taxon_name 
      Project.find(@project_id).root_taxon_name
    end
    
    def parent_taxon_name_id
      parent_taxon_name.id
    end

    def build_taxon_names
      i = 0

      namespace_castor = Namespace.find_by(:name, "Castor")
      taxon_names = {}

      csv.each do |row|
        i += 1
        parse_result = BatchLoad::RowParse.new
        parse_result.objects[:taxon_names] = []

        @processed_rows[i] = parse_result

        begin
          next if row['rank'] == "complex"
          next if row['rank'] == "species group"
          next if row['rank'] == "series"
          next if row['taxon_name'] == "unidentified"
      
          taxon_name_identifier_castor_text = row["guid"]
          taxon_name_identifier_castor = { namespace: namespace_castor,
                                           type: "Identifier::Local::TaxonConcept",
                                           identifier: taxon_name_identifier_castor_text
          }

          taxon_name_identifiers = []
          taxon_name_identifiers.push(taxon_name_identifier_castor) if !taxon_name_identifier_castor_text.blank?

          protonym_attributes = {
            name: row['taxon_name'],
            year_of_publication: year_of_publication(row['author_year']),
            rank_class: Ranks.lookup(@nomenclature_code.to_sym, row['rank']),
            by: @user,
            also_create_otu: @also_create_otu,
            project: @project,
            verbatim_author: verbatim_author(row['author_year']),
            taxon_name_authors_attributes: taxon_name_authors_attributes(verbatim_author(row['author_year'])),
            identifiers_attributes: taxon_name_identifiers
          }

          p = Protonym.new(protonym_attributes)
          taxon_name_id = row['id']
          parent_taxon_name_id = row['parent_id']
          taxon_names[taxon_name_id] = p

          if taxon_names[parent_taxon_name_id].nil?
            p.parent = parent_taxon_name
          else
            p.parent = taxon_names[parent_taxon_name_id]
          end
          
          parse_result.objects[:taxon_names].push p
        end
      end
    end

    def build
      if valid?
        build_taxon_names
        @processed = true
      end
    end

    private

    def year_of_publication(author_year)
      split_author_year = author_year.split(" ")
      year = split_author_year[split_author_year.length - 1]
      return year
    end

    def verbatim_author(author_year)
      split_author_year = author_year.split(" ")
      verbatim_author = split_author_year[0...(split_author_year.length - 1)]
      return verbatim_author
    end

    def taxon_name_authors_attributes(author_year)
      author_info = verbatim_author(author_year)

      multiple_author_query = "and"
      multiple_author_index = author_info.index(multiple_author_query)

      if multiple_author_index.nil?
        return [author_info(author_info)]
      else
        multiple_author_index += multiple_author_query.length
        split_author_info = author_info.split(multiple_author_query)

        author_infos = []

        split_author_info.each do |author_str|
          author_infos.push author_info(author_str)
        end

        return author_infos
      end
    end

    def author_info(author_string)
      seperator_query = " "
      separator_index = author_string.index(seperator_query)

      last_name = author_string
      first_name = ""

      if !separator_index.nil?
        separator_index += seperator_query.length
        split_author_info = author_string.split(seperator_query)
        last_name = split_author_info[0]
        first_name = split_author_info[1] 
      end

      return { last_name: last_name, first_name: first_name, suffix: "suffix" }
    end
  end
end
