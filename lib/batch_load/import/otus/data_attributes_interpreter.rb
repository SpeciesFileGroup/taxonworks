# TODO: THIS IS A GENERATED STUB, it does not function
module BatchLoad
  class Import::Otus::DataAttributesInterpreter < BatchLoad::Import

    # @param [Hash] args
    def initialize(**args)
      super(args)
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/BlockNesting
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
          # assume we will be creating a new da
          da = ImportAttribute.new(import_predicate: row['predicate'],
                                   value: row['value'],
                                   project_id: real_project_id)
          das = BatchLoad::ColumnResolver.import_attribute(row)

          otus = BatchLoad::ColumnResolver.otu(row)
          find_name = row['otuname']
          if otus.no_matches? # can't find any by that name
            # find_name = row['otuname']
            otus.assign(Otu.new(name: find_name, project_id: real_project_id))
          end

          # search for (and remove) pairs (otu and da) which are already represented in the database.
          [otus.item, otus.items].flatten.compact.each do |l_otu| # found one or more otus
            if l_otu.persisted? # means it was found in the database, not 'new' here
              [das.item, das.items].flatten.compact.each do |l_da|
                if l_da.attribute_subject == l_otu
                  if otus.item == l_otu
                    otus.assign([])
                  else # reamove otu and da from thier respective collections.
                    group = otus.items.delete_if { |_otu| _otu == l_otu }
                    otus.assign(group)
                    group = das.items.delete_if { |_da| _da == l_da }
                    das.assign(group)
                  end
                  parse_result.parse_errors << 'otu/predicate/value combination already exists.'
                  break
                end
              end
            end
          end
          if otus.multiple_matches?
            parse_result.parse_errors << 'Can\'t resolve multiple found otus.'
            otus.assign([])
          else
            das.assign(da) # finished with the found das, prepare a new one to attach to a remaining otu
          end


          parse_result.parsed = true
          parse_result.objects[:otu].push(otus.item)
          parse_result.parse_errors << otus.error_messages if otus.error_messages.any?
          parse_result.objects[:data_attribute].push(das.item)
          parse_result.parse_errors << das.error_messages if das.error_messages.any?

          @total_data_lines += 1 if find_name.present?
        rescue => _e
          raise(_e)
        end
      end

      @total_lines = i
    end

    # rubocop:enable Metrics/MethodLength
    # Iterates in line order and attempts to save each record
    # @return [Boolean] true
    def create
      @create_attempted = true
      if ready_to_create?
        sorted_processed_rows.each_value do |processed_row|
          otu = processed_row.objects[:otu].flatten.first
          d_a = processed_row.objects[:data_attribute].flatten.first
          unless otu.nil? or d_a.nil?
            if d_a.valid? && otu.valid?
              otu.save if otu.new_record?
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

    # rubocop:enable Metrics/BlockNesting

    # @return [Boolean] true if build process has run
    def build
      if valid?
        build_da_for_otus
        @processed = true
      end
    end
  end
end
