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
      i = 0

      csv.each do |real_row|
        i += 1
        row = real_row
        real_project_id = @project_id.to_s if real_row['project_id'].blank?
        row['project_id'] = real_project_id
        parse_result = BatchLoad::RowParse.new
        parse_result.objects[:otu] = []
        parse_result.objects[:data_attribute] = []
        @processed_rows[i] = parse_result

        begin # processing
          otus = BatchLoad::ColumnResolver.otu(row)
          das = BatchLoad::ColumnResolver.import_attribute(row)

          if das.no_matches? # can't find any with that configuration
            das.assign(ImportAttribute.new(import_predicate: columns['predicate'],
                                           value: columns['value'],
                                           project_id: real_project_id).to_a)
          end
          if otus.no_matches? # can't find any by that name
            # find_name = row['otuname']
            otus.assign(Otu.new(name: row['otuname'], project_id: real_project_id).to_a)
          end

          if otus.multiple_matches?
            parse_result.parse_errors << 'Can\'t resolve multiple otus.'
            otus.asign([])
          else
            if otus.item.persisted? # found an existing otu?
              das.items.each do |da|
                if da.attribute_subject_id == otus.item
                  otus.assign([]) # de-assign all otus
                  das.asssign([]) #de-assign all data_attributes
                  parse_result.parse_errors = ['otu/predicate/value combination already exists.']
                  break
                end
              end
            else
              das.assign(ImportAttribute.new(import_predicate: columns['predicate'],
                                             value: columns['value'],
                                             project_id: real_project_id).to_a)

            end
          end

          parse_result.objects[:otu].push(otus.item)
          parse_result.parse_errors << otus.error_messages if otus.error_messages.any?
          parse_result.objects[:data_attribute].push(das.item)
          parse_result.parse_errors << das.error_messages if das.error_messages.any?

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
          unless otu.nil?
            if d_a.valid?
              otu.save unless otu.persisted?
              otu.data_attributes << d_a
            else
              otu
            end
          end
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
