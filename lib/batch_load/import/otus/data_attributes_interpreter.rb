# TODO: THIS IS A GENERATED STUB, it does not function
module BatchLoad
  class Import::Otus::DataAttributesInterpreter < BatchLoad::Import

    # @param [Hash] args
    def initialize(**args)
      super(args)
    end

    # @return [Integer] total data lines
    def build_da_for_otus
      @total_data_lines = 0
      i                 = 0

      csv.each do |real_row|
        i                 += 1
        row = real_row
        row['project_id'] = @project_id.to_s if real_row['project_id'].blank?

        parse_result                          = BatchLoad::RowParse.new
        parse_result.objects[:otu]            = []
        parse_result.objects[:data_attribute] = []
        @processed_rows[i]                    = parse_result

        begin # processing
          find_name                    = row['otuname']
          otu_data_attribute_predicate = row['predicate']
          otu_data_attribute_value     = row['value']
          otu_data_attribute           = {type:             'ImportAttribute',
                                          import_predicate: otu_data_attribute_predicate,
                                          value:            otu_data_attribute_value,
                                          project_id:       @project_id}

          otu = BatchLoad::ColumnResolver.otu(row).item
          if otu.blank? # can't find any by that name
            otu = Otu.new(name: find_name, project_id: @project_id)
          end

          parse_result.objects[:otu].push(otu)
          parse_result.objects[:data_attribute].push(DataAttribute.new(otu_data_attribute))

          @total_data_lines += 1 if otu.present?
        rescue
          # ....
        end
      end

      @total_lines = i
    end

    # Iterates in line order and attempts to save each record
    # @return [Boolean] true
    def create
      @create_attempted = true
      if ready_to_create?
        sorted_processed_rows.each_value do |processed_row|
          otu = processed_row.objects[:otu].first
          d_a = processed_row.objects[:data_attribute].first
          otu.save unless otu.persisted?
          otu.data_attributes << d_a
        end
      else
        @errors << "Import level #{import_level} has prevented creation." unless import_level_ok?
        @errors << 'CSV has not been processed.' unless processed?
        @errors << 'One of user_id, project_id or file has not been provided.' unless valid?
      end
      true
    end

    def build
      if valid?
        build_da_for_otus
        @processed = true
      end
    end
  end
end
