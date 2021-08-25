class DatasetRecord::DarwinCore::Taxon < DatasetRecord::DarwinCore

  KNOWN_KEYS_COMBINATIONS = [
    %i{uninomial},
    %i{uninomial rank parent},
    %i{genus species},
    %i{genus species infraspecies},
    %i{genus subgenus species},
    %i{genus subgenus species infraspecies}
  ]

  PARSE_DETAILS_KEYS = %i(uninomial genus species infraspecies)

  def import(dwc_data_attributes = {})
    begin
      DatasetRecord.transaction do
        self.metadata.delete("error_data")

        unless metadata["is_synonym"]
          nomenclature_code = (get_field_value("nomenclaturalCode") || import_dataset.metadata["nomenclature_code"]).downcase.to_sym
          parse_results_details = Biodiversity::Parser.parse(get_field_value("scientificName") || "")[:details]&.values&.first

          parse_results = Biodiversity::Parser.parse(get_field_value(:scientificName) || "")
          parse_results_details = parse_results[:details]
          parse_results_details = (parse_results_details&.keys - PARSE_DETAILS_KEYS).empty? ? parse_results_details.values.first : nil if parse_results_details

          raise DarwinCore::InvalidData.new({
            "scientificName": parse_results[:qualityWarnings] ?
              parse_results[:qualityWarnings].map { |q| q[:warning] } :
              ["Unable to parse scientific name. Please make sure it is correctly spelled."]
          }) unless (1..3).include?(parse_results[:quality]) && parse_results_details

          raise "UNKNOWN NAME DETAILS COMBINATION" unless KNOWN_KEYS_COMBINATIONS.include?(parse_results_details.keys - [:authorship])

          name_key = parse_results_details[:uninomial] ? :uninomial : (parse_results_details.keys - [:authorship]).last
          name_details = parse_results_details[name_key]

          name = name_details.kind_of?(Array) ? name_details.first[:value] : name_details

          authorship = parse_results_details.dig(:authorship, :normalized) || get_field_value("scientificNameAuthorship")

          author_name = nil

          if nomenclature_code == :iczn
            if (authorship_matchdata = authorship.match(/\(?(?<author>.+?),? (?<year>\d{4})?\)?/))

              author_name = authorship_matchdata[:author]
              year = authorship_matchdata[:year]

              # author name should be wrapped in parentheses if the verbatim authorship was
              if authorship.start_with?("(") and authorship.end_with?(")")
                author_name = "(" + author_name + ")"
              end
            end

          else  # Fall back to simple name + date parsing
            author_name = verbatim_author(authorship)
            year = year_of_publication(authorship)
          end

          # TODO should a year provided in namePublishedInYear overwrite the parsed value?
          year ||= get_field_value("namePublishedInYear")

          rank = get_field_value("taxonRank")
          is_hybrid = metadata["is_hybrid"] # TODO: NO...

          if metadata["parent"].nil?
            parent = project.root_taxon_name
          else
            parent = TaxonName.find(get_parent.metadata["imported_objects"]["taxon_name"]["id"])
          end

          protonym_attributes = {
            name: name,
            parent: parent,
            rank_class: Ranks.lookup(nomenclature_code, rank),
            also_create_otu: false,
            verbatim_author: author_name,
            year_of_publication: year
          }

          if Protonym.find_by(protonym_attributes.slice(:name, :parent, :rank_class, :year_of_publication))
            raise DarwinCore::InvalidData.new({ "scientificName" => ["Protonym #{name} with parent #{parent.name} and author #{authorship} already exists"]})
          end

          taxon_name = Protonym.new(protonym_attributes)
          taxon_name.taxon_name_classifications.build(type: TaxonNameClassification::Icn::Hybrid) if is_hybrid
          taxon_name.data_attributes.build(import_predicate: 'DwC-A import metadata', type: 'ImportAttribute', value: {
            scientificName: get_field_value("scientificName"),
            scientificNameAuthorship: get_field_value("scientificNameAuthorship"),
            taxonRank: get_field_value("taxonRank"),
            metadata: metadata
          })

          if taxon_name.save
            self.metadata[:imported_objects] = { taxon_name: { id: taxon_name.id } }
            self.status = "Imported"
          else
            self.status = "Errored"
            self.metadata[:error_data] = {
              messages: taxon_name.errors.messages
            }
          end
        else
          self.status = "Unsupported"
          self.metadata[:error_data] = {
            messages: { unsupported: ["Synonym taxa is not supported at this time. Please revisit this record later."] }
          }
        end

        save!

        if status == "Imported"
          taxon_id = get_field_value("taxonID")

          import_dataset.core_records.where(status: "NotReady")
            .where(id: import_dataset.core_records_fields
              .at([get_field_mapping(:parentNameUsageID), get_field_mapping(:acceptedNameUsageID)])
              .with_value(taxon_id)
              .select(:dataset_record_id)
            ).update_all(status: "Ready")
        end
      end
    rescue DarwinCore::InvalidData => invalid
      self.status = "Errored"
      self.metadata["error_data"] = { messages: invalid.error_data }
    rescue ActiveRecord::RecordInvalid => invalid
      self.status = "Errored"
      self.metadata["error_data"] = {
        messages: invalid.record.errors.messages
      }
    rescue StandardError => e
      raise if Rails.env.development?
      self.status = "Failed"
      self.metadata[:error_data] = {
        exception: {
          message: e.message,
          backtrace: e.backtrace
        }
      }
      save!
    end

    self
  end

  private

  def get_parent
    import_dataset.core_records.where(id: import_dataset.core_records_fields
                                                        .at(get_field_mapping(:taxonID))
                                                        .with_value(get_field_value(:parentNameUsageID))
                                                        .select(:dataset_record_id)
    ).first
  end

  def data_field_changed(index, value)
    if index == get_field_mapping(:parentNameUsageID) && status == "NotReady"
      self.status = "Ready" if %w[Ready Imported].include? get_parent&.status
    end
  end


  # @param [String] author_year
  # @return [String, nil]
  def year_of_publication(author_year)
    return nil if author_year.blank?
    split_author_year = author_year.split(' ')
    year = split_author_year[split_author_year.length - 1]
    year =~ /\A\d+\z/ ? year : ''
  end

  # @param [String] author_year_string
  # @return [String, nil]
  def verbatim_author(author_year_string)
    return nil if author_year_string.blank?
    author_end_index = author_year_string.rindex(' ')
    author_end_index ||= author_year_string.length
    author_year_string[0...author_end_index]
  end

end
