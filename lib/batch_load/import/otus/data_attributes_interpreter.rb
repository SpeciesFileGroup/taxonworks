# TODO: THIS IS A GENERATED STUB, it does not function
module BatchLoad
  class Import::Otus::DataAttributesInterpreter < BatchLoad::Import

    # Whether or not to create unfound OTUs
    attr_accessor :create_new_otu

    # Whether or not to create unfound Predicates
    attr_accessor :create_new_predicate

    # Whether or not to create citationss
    attr_accessor :create_citation

    # Import or Internal Attribute
    attr_accessor :type_select

    # Sourde for citation
    attr_accessor :source

    SAVE_ORDER = [:predicate, :otu, :data_attribute, :citation]

    # @param [Hash] args
    def initialize(**args)
      @create_new_otu = args.delete(:create_new_otu).present?
      @create_new_predicate = args.delete(:create_new_predicate).present?
      @type_select = args.delete(:type_select)
      source_id = args.delete(:source_id)
      @source = Source.find(source_id) if source_id.present?
      @create_citation = @source.present?
      super(**args)
    end

    # @return [Integer] total data lines
    def build_da_for_otus
      @total_data_lines = 0
      i = 0
      import_klass = type_select.start_with?('im')
      att_klass = (type_select.capitalize + 'Attribute').safe_constantize

      csv.each do |real_row|
        i += 1
        row = real_row
        real_project_id = @project_id.to_s if real_row['project_id'].blank?
        row['project_id'] = real_project_id
        parse_result = BatchLoad::RowParse.new
        parse_result.objects[:otu] = []
        parse_result.objects[:data_attribute] = []
        parse_result.objects[:citation] = []  # if create_citation
        parse_result.objects[:predicate] = [] # unless import_klass
        @processed_rows[i] = parse_result

        begin # processing
          # assume we will be creating a new da
          predicate = row['predicate']
          new_da_attributes = {value: row['value'], project_id: real_project_id}
          new_da_attributes[:citations_attributes] = [{source_id: @source.id,
                                                       project_id: real_project_id}] if create_citation
          ias = BatchLoad::ColumnResolver.data_attribute(row, type_select)
          if import_klass
            new_da_attributes[:import_predicate] = predicate
          else
            new_cvt = Predicate.find_or_initialize_by(
              name: predicate,
              definition: "Imported from #{file.original_filename}",
              project_id: real_project_id)
          end
          new_da = att_klass.new(new_da_attributes)

          otus = BatchLoad::ColumnResolver.otu(row)
          find_name = row['otuname']

          if otus.no_matches? # can't find any by that name
            otus.assign(Otu.new(name: find_name, project_id: real_project_id))
          end

          # search for (and remove) pairs (otu and da) which are already represented in the database.
          [otus.item, otus.items].flatten.compact.each do |l_otu| # found one or more otus
            if l_otu.persisted? # means it was found in the database, not 'new' here
              [ias.item, ias.items].flatten.compact.each do |l_ia|
                if l_ia.attribute_subject == l_otu
                  parse_result.parse_errors << 'otu/predicate/value combination already exists.'
                  break
                end
              end
            end
          end
          parse_result.parse_errors << 'Can\'t resolve multiple found otus.' if otus.multiple_matches?
          ias.assign(new_da) # finished with the found das, prepare a new one to attach to a remaining otu

          parse_result.parsed = true
          otu_valid = otus.item&.valid?
          # connect data_attribute to otu
          ias.item.attribute_subject = otus.item
          # connect citation to otu
          if create_citation
            cite = new_da.citations.first
            cite.citation_object = otus.item
            # add citation
            parse_result.objects[:citation].push(cite) #if otu_valid
            cite.valid?
            parse_result.parse_errors << cite.errors.messages if cite.errors.messages.any?
          end
          unless import_klass
            # connect cvt to data_attribute
            ias.item.predicate = new_cvt
            # add predicate
            parse_result.objects[:predicate].push(new_cvt) if new_cvt.present? # (new_cvt.present? && otu_valid)
            parse_result.parse_errors << new_cvt.errors.messages if new_cvt.errors.messages.any?
          end
          # add data_attribute
          parse_result.objects[:data_attribute].push(ias.item) #if otu_valid
          parse_result.parse_errors << ias.error_messages if ias.error_messages.any?

          # add otu
          parse_result.objects[:otu].push(otus.item) #if otu_valid
          parse_result.parse_errors << otus.error_messages if otus.error_messages.any?

          @total_data_lines += 1 # if find_name.present?
        rescue => _e
          raise(_e)
        end
      end

      @total_lines = i
    end

    # Remove new objects which are not wanted, per args
    # @return [Boolean] true
    def create
      sorted_processed_rows.each_value do |processed_row|
        otu = processed_row.objects[:otu].first
        d_a = processed_row.objects[:data_attribute].first
        cvt = processed_row.objects[:predicate].first

        if otu&.valid? && d_a&.valid?
          if (not create_new_predicate)
            if cvt&.new_record?
              processed_row.objects[:predicate] = []
              processed_row.objects[:data_attribute] = []
              processed_row.objects[:citation] = []
            end
          end
          if (not create_new_otu)
            if otu&.new_record?
              processed_row.objects[:otu] = []
              processed_row.objects[:predicate] = []
              processed_row.objects[:data_attribute] = []
              processed_row.objects[:citation] = []
            end
          end
        else # wipe out all objects
          processed_row.objects.each_key { |kee| processed_row.objects[kee] = [] }
        end
      end
      super
    end

    # @return [Boolean] true if build process has run
    def build
      if valid?
        build_da_for_otus
        @processed = true
      end
    end
  end
end
