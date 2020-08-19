class DatasetRecord::DarwinCore::Occurrence < DatasetRecord

  DWC_CLASSIFICATION_TERMS = %w{kingdom phylum class order family} # genus, subgenus, specificEpithet and infraspecificEpithet are extracted from scientificName

  def import
    begin
      DatasetRecord.transaction do
        self.metadata.delete("error_data")

        fields_mapping = get_fields_mapping
        parse_details = metadata.dig("parse_results", "details").first

        names = DWC_CLASSIFICATION_TERMS.map { |t| [t, data_fields[fields_mapping[t]]&.dig("value")] }

        names << ["genus", parse_details.dig("genus", "value")]
        names << ["subgenus", parse_details.dig("infragenericEpithet", "value")]
        names << ["species", parse_details.dig("specificEpithet", "value")]
        names << ["subspecies", parse_details["infraspecificEpithets"]&.first&.dig("value")]

        names.reject! { |v| v[1].nil? }

        rank = data_fields[fields_mapping["taxonRank"]]&.dig("value")

        names.last[0] = rank unless rank.blank?

        # TODO: In case of existing duplicate protonyms this may contribute with duplication even further by traversing names by incorrect parent.
        # TODO2: Re-evaluate use of TaxonWorks::Vendor::Biodiversity::Result
        names.map! do |name|
          { rank_class: Ranks.lookup(:iczn, name[0]), name: name[1] }
        end
        names.last.merge!({ verbatim_author: data_fields[fields_mapping["scientificNameAuthorship"]]&.dig("value") })

        parent = project.root_taxon_name
        names.detect do |name|
          parent = Protonym.create_with(also_create_otu: true).find_or_create_by(name.merge({ parent: parent }))
          !parent.persisted?
        end

        if parent.persisted?
          self.metadata["imported_objects"] = { taxon_name: { id: parent.id } }
          self.status = "Imported"
        else
          self.status = "Errored"
          self.metadata["error_data"] = {
            messages: parent.errors.messages
          }
        end

        save!
      end
    rescue StandardError => e
      self.status = "Failed"
      self.metadata["error_data"] = {
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

end
