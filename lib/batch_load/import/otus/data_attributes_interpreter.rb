# TODO: THIS IS A GENERATED STUB, it does not function
module BatchLoad
  class Import::Otus::DataAttributesInterpreter < BatchLoad::Import

    attr_accessor :create_new_otu, :create_citation, :create_new_predicate,
                  :type_select, :source

    # @param [Hash] args
    def initialize(**args)
      @create_new_otu = args.delete(:create_new_otu).present?
      @create_new_predicate = args.delete(:create_new_predicate).present?
      @type_select = args.delete(:type_select)
      source_id = args.delete(:source_id)
      @source = Source.find(source_id) if source_id.present?
      @create_citation = @source.present?
      super(args)
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/BlockNesting
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
        parse_result.objects[:citation] = [] if create_citation
        parse_result.objects[:predicate] = [] unless import_klass
        @processed_rows[i] = parse_result

        begin # processing
          # assume we will be creating a new da
          predicate = row['predicate']
          new_da_attributes = {value: row['value'], project_id: real_project_id}
          new_da_attributes[:citations_attributes] = [{source_id: @source.id,
                                                       project_id: real_project_id}] if create_citation.present?
          ias = BatchLoad::ColumnResolver.data_attribute(row, type_select)
          if import_klass
            new_da_attributes[:import_predicate] = predicate
          else
            cvt = ControlledVocabularyTerm.find_or_initialize_by(name: predicate, project_id: real_project_id)
            new_da_attributes[:controlled_vocabulary_term_id] =
                ias.item.blank? ? cvt&.id : ias.item.controlled_vocabulary_term_id
          end
          new_da = att_klass.new(new_da_attributes)

          otus = BatchLoad::ColumnResolver.otu(row)
          find_name = row['otuname']
          if otus.no_matches? # can't find any by that name
            # find_name = row['otuname']
            otus.assign(Otu.new(name: find_name, project_id: real_project_id))
          end

          # search for (and remove) pairs (otu and da) which are already represented in the database.
          [otus.item, otus.items].flatten.compact.each do |l_otu| # found one or more otus
            if l_otu.persisted? # means it was found in the database, not 'new' here
              [ias.item, ias.items].flatten.compact.each do |l_ia|
                if l_ia.attribute_subject == l_otu
                  # if otus.item == l_otu
                  # otus.assign([])
                  # else # reamove otu and da from thier respective collections.
                  # group = otus.items.delete_if { |_otu| _otu == l_otu }
                  # otus.assign(group)
                  # end
                  parse_result.parse_errors << 'otu/predicate/value combination already exists.'
                  break
                end
              end
            end
          end
          if otus.multiple_matches?
            parse_result.parse_errors << 'Can\'t resolve multiple found otus.'
            otus.assign([otus.items.first])
            # else
            #   das.assign(new_da) # finished with the found das, prepare a new one to attach to a remaining otu
          end
          ias.assign(new_da) # finished with the found das, prepare a new one to attach to a remaining otu
          cite = new_da.citations.first
          cite.valid? if cite.present?

          parse_result.parsed = true
          parse_result.objects[:otu].push(otus.item)
          parse_result.parse_errors << otus.error_messages if otus.error_messages.any?
          parse_result.objects[:data_attribute].push(ias.item)
          parse_result.parse_errors << ias.error_messages if ias.error_messages.any?
          if cite.present?
            parse_result.objects[:citation].push(cite)
            parse_result.parse_errors << cite.errors.messages if cite.errors.messages.any?
          end
          unless import_klass
            parse_result.objects[:predicate].push(cvt) unless cvt.blank?
            parse_result.parse_errors << cvt.errors.messages if cvt.errors.messages.ant?
          end
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
      super
      return
      @create_attempted = true
      if ready_to_create?
        sorted_processed_rows.each_value do |processed_row|
          otu = processed_row.objects[:otu].flatten.first
          d_a = processed_row.objects[:data_attribute].flatten.first
          cite = processed_row.objects[:citation].flatten.first
          cvt = processed_row.objects[:predicate].flatten.first
          unless otu.nil? or d_a.nil?
            if d_a.valid? && otu.valid?
              if otu.new_record?
                otu.save if create_new_otu.present?
              end
              if create_citation
                d_a.citations << cite
              end
              if cvt.present? && cvt.valid? && create_new_predicate
                cvt.save
              end
              otu.data_attributes << d_a
              otu
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
