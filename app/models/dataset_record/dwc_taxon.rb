class DatasetRecord::DwcTaxon < DatasetRecord

  KNOWN_KEYS_COMBINATIONS = [
    ["uninomial"],
    ["genus", "specificEpithet"],
    ["genus", "specificEpithet", "infraspecificEpithets"]
  ]

  def import
    begin
      DatasetRecord.transaction do
        field_mapping = import_dataset.metadata["core_headers"].each.with_index.inject({}) { |m, (h, i)| m.merge({ h => i}) }
        
        unless metadata["is_synonym"]
          nomenclature_code = import_dataset.metadata["nomenclature_code"].downcase.to_sym
          parse_results_details = metadata["parse_results"]["details"].first

          raise "UNKNOWN NAME DETAILS COMBINATION" unless KNOWN_KEYS_COMBINATIONS.include?(parse_results_details.keys)

          name_key = parse_results_details.keys.last
          name_details = parse_results_details[name_key]
          name_details = name_details.first if name_details.kind_of?(Array)

          name = name_details["value"]
          authorship = name_details.dig("authorship", "value")
          rank = data_fields[field_mapping["taxonRank"]]["value"]
          is_hybrid = metadata["is_hybrid"]

          if metadata["parent"].nil?
            parent = project.root_taxon_name
          else
            parent = TaxonName.find(get_parent(field_mapping).metadata["imported_objects"]["taxon_name"]["id"])
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
            scientificName: data_fields[field_mapping["scientificName"]]["value"],
            scientificNameAuthorship: data_fields[field_mapping["scientificNameAuthorship"]]["value"],
            taxonRank: data_fields[field_mapping["taxonRank"]]["value"],
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
            messages: ["Synonym taxa is not supported at this time. Please revisit this record later."]
          }
        end

        save!

        if status == "Imported"
          taxon_id = data_fields[field_mapping["taxonID"]]["value"]

          DatasetRecord::DwcTaxon
            .where(import_dataset: self.import_dataset, status: "NotReady")
            .where("data_fields -> :parent_field ->> 'value' = :parent_id OR data_fields -> :accepted_field ->> 'value' = :accepted_id",
              {
                parent_field: field_mapping["parentNameUsageID"], parent_id: taxon_id,
                accepted_field: field_mapping["acceptedNameUsageID"], accepted_id: taxon_id
              }
            ).each { |r| r.update!(status: "Ready") }
        end
      end
    rescue StandardError => e
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

  def get_parent(field_mapping)
    import_dataset.dataset_records.where("data_fields -> #{field_mapping["taxonID"]} ->> 'value' = ?", data_fields[field_mapping["parentNameUsageID"]]["value"]).first
  end
end
