class DatasetRecord::DarwinCore::Taxon < DatasetRecord::DarwinCore

  KNOWN_KEYS_COMBINATIONS = [ # TODO: Review subGenus/infraSpecies when biodiversity gem is updated
    %i{uninomial},
    %i{uninomial rank parent},
    %i{genus species},
    %i{genus species infraSpecies},
    %i{genus subGenus species},
    %i{genus subGenus species infraSpecies}
  ]

  def import
    begin
      DatasetRecord.transaction do
        fields_mapping = get_fields_mapping
        
        unless metadata["is_synonym"]
          nomenclature_code = import_dataset.metadata["nomenclature_code"].downcase.to_sym
          parse_results_details = Biodiversity::Parser.parse(get_field_value("scientificName") || "")[:details]&.values&.first

          raise "UNKNOWN NAME DETAILS COMBINATION" unless KNOWN_KEYS_COMBINATIONS.include?(parse_results_details.keys - [:authorship])

          name_key = (parse_results_details.keys - [:authorship]).last
          name_details = parse_results_details[name_key]

          name = name_details.kind_of?(Array) ? name_details.first[:value] : name_details

          authorship = parse_results_details.dig(:authorship, :normalized)
          rank = data_fields[fields_mapping["taxonRank"]]["value"]
          is_hybrid = metadata["is_hybrid"] # TODO: NO...

          if metadata["parent"].nil?
            parent = project.root_taxon_name
          else
            parent = TaxonName.find(get_parent(fields_mapping).metadata["imported_objects"]["taxon_name"]["id"])
          end

          protonym_attributes = {
            name: name,
            parent: parent,
            rank_class: Ranks.lookup(nomenclature_code, rank),
            also_create_otu: false,
            verbatim_author: authorship
          }

          taxon_name = Protonym.new(protonym_attributes)
          taxon_name.taxon_name_classifications.build(type: TaxonNameClassification::Icn::Hybrid) if is_hybrid
          taxon_name.data_attributes.build(import_predicate: 'DwC-A import metadata', type: 'ImportAttribute', value: {
            scientificName: data_fields[fields_mapping["scientificName"]]["value"],
            scientificNameAuthorship: data_fields[fields_mapping["scientificNameAuthorship"]]["value"],
            taxonRank: data_fields[fields_mapping["taxonRank"]]["value"],
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
          taxon_id = data_fields[fields_mapping["taxonID"]]["value"]

          DatasetRecord::DarwinCore::Taxon
            .where(import_dataset: self.import_dataset, status: "NotReady")
            .where("data_fields -> :parent_field ->> 'value' = :parent_id OR data_fields -> :accepted_field ->> 'value' = :accepted_id",
              {
                parent_field: fields_mapping["parentNameUsageID"], parent_id: taxon_id,
                accepted_field: fields_mapping["acceptedNameUsageID"], accepted_id: taxon_id
              }
            ).each { |r| r.update!(status: "Ready") }
        end
      end
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

  def get_fields_mapping
    import_dataset.metadata["core_headers"].each.with_index.inject({}) { |m, (h, i)| m.merge({ h => i, i => h}) }
  end

  def get_parent(fields_mapping)
    import_dataset.dataset_records.where("data_fields -> #{fields_mapping["taxonID"]} ->> 'value' = ?", data_fields[fields_mapping["parentNameUsageID"]]["value"]).first
  end

  def data_field_changed(index, value)
    fields_mapping = get_fields_mapping

    if fields_mapping[index] == "parentNameUsageID" && status == "NotReady"
      self.status = "Ready" if ["Ready", "Imported"].include? get_parent(fields_mapping)&.status
    end
  end
end
