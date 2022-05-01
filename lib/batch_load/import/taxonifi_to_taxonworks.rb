module BatchLoad

  # Batch loading of CSV formatted taxon names via Taxonifi
  class Import::TaxonifiToTaxonworks < BatchLoad::Import

    # The Taxonifi Name collection
    attr_accessor :name_collection

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

    # @param [Hash] args
    def initialize(nomenclature_code: nil, parent_taxon_name_id: nil, also_create_otu: false, **args)
      @nomenclature_code = nomenclature_code
      @also_create_otu = also_create_otu
      @parent_taxon_name_id = parent_taxon_name_id

      super(**args)
    end

    # @return [TaxonName]
    def parent_taxon_name
      return @parent_taxon_name if @parent_taxon_name
      if !@parent_taxon_name_id.blank?
        begin
          @parent_taxon_name = TaxonName.find(parent_taxon_name_id)
        rescue ActiveRecord::RecordNotFound
          @errors = ['Provided parent taxon name id not valid.']
        end
      else
        @parent_taxon_name = Project.find(@project_id).root_taxon_name
      end

      @parent_taxon_name
    end

    # @return [Symbol]
    def nomenclature_code
      @nomenclature_code ||= @parent_taxon_name.rank_class.nomenclatural_code
      @nomenclature_code.to_sym
    end

    # @return [Boolean]
    def build
      if valid?
        build_name_collection
        build_protonyms
        @processed = true
      end
    end

    protected

    def build_name_collection
      begin
        @name_collection ||= ::Taxonifi::Lumper.create_name_collection(csv: csv)
      rescue Taxonifi::Assessor::RowAssessor::RowAssessorError => e
        @file_errors.push 'Error assessing a row of data in the inputfile.'
      end
    end

    # @return [Integer]
    def build_protonyms
      if name_collection.nil?
        @file_errors.push 'No names were readable in the file.'
        return
      end

      parents = {}

      total_lines = 0

      name_collection.collection.each do |n|
        i  = n.row_number + 1
        rp = nil

        if @processed_rows[i]
          rp = @processed_rows[i]
        else
          rp = BatchLoad::RowParse.new
          @processed_rows[i] = rp
        end

        p = Protonym.new(
          name: n.name,
          year_of_publication: n.year.to_s,
          rank_class: Ranks.lookup(nomenclature_code, n.rank),
          by: @user,
          also_create_otu: also_create_otu,
          project: @project,
          verbatim_author: (n.parens ? n.author_with_parens : nil),
          taxon_name_authors_attributes: taxon_name_authors_hash(n)
        )

        p.parent = (n.parent.nil? ? parent_taxon_name : parents[n.parent.id])

        rp.objects[:protonyms] ||= []
        rp.objects[:protonyms].push(p)

        parents[n.id] = p

        total_lines = i if total_lines < i
      end

      @total_data_lines = total_lines

      true
    end

    # @param [TaxonName] taxonifi_name
    # @return [Array]
    def taxon_name_authors_hash(taxonifi_name)
      author_attributes = []
      taxonifi_name.authors.each_with_index do |a,i|
        suffix = a.suffix.join(' ') if !a.suffix.nil?
        author_attributes.push({
          last_name: a.last_name,
          first_name: a.first_name,
          prefix: a.initials_string,
          suffix: suffix,
        })
      end
      author_attributes
      # author_attributes.reverse
    end

  end
end
