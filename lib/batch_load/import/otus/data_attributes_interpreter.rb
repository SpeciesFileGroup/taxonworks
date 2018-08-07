# TODO: THIS IS A GENERATED STUB, it does not function
module BatchLoad
  class Import::Otus::DataAttributesInterpreter < BatchLoad::Import

    # @param [Hash] args
    def initialize(**args)
      super(args)
    end

    # TODO: update this
    def build_da_for_otus
      @total_data_lines = 0
      i                 = 0

      # loop throw rows
      csv.each do |row|
        i += 1

        parse_result               = BatchLoad::RowParse.new
        parse_result.objects[:otu] = []

        @processed_rows[i] = parse_result

        begin # processing
          otu_data_attribute_predicate = row['predicate']
          otu_data_attribute_value     = row['value']
          otu_data_attribute           = {type:             'ImportAttribute',
                                          import_predicate: otu_data_attribute_predicate,
                                          value:            otu_data_attribute_value}

          otu_data_attributes          = []
          otu_data_attributes.push(otu_data_attribute) unless otu_data_attribute_predicate.blank?

          otu_attributes = {
              name: row['otuname'],
              data_attribute_attributes: otu_data_attributes
          }
          otu = Otu.new(otu_attributes)
          parse_result.objects[:otu].push otu

          @total_data_lines += 1 if otu.present?
        rescue
          # ....
        end
      end

      @total_lines = i
    end

    def build
      if valid?
        build_da_for_otus
        @processed = true
      end
    end
  end
end
