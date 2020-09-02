class DatasetRecord::DarwinCore::Occurrence < DatasetRecord

  DWC_CLASSIFICATION_TERMS = %w{kingdom phylum class order family} # genus, subgenus, specificEpithet and infraspecificEpithet are extracted from scientificName

  def import
    begin
      DatasetRecord.transaction do
        self.metadata.delete("error_data")

        parse_details = metadata.dig("parse_results", "details").first

        names = DWC_CLASSIFICATION_TERMS.map { |t| [t, get_field_value(t)] }

        names << ["genus", parse_details.dig("genus", "value")]
        names << ["subgenus", parse_details.dig("infragenericEpithet", "value")]
        names << ["species", parse_details.dig("specificEpithet", "value")]
        names << ["subspecies", parse_details["infraspecificEpithets"]&.first&.dig("value")]

        names.reject! { |v| v[1].nil? }

        rank = get_field_value("taxonRank")

        names.last[0] = rank unless rank.blank?

        # TODO: In case of existing duplicate protonyms this may contribute with duplication even further by traversing names by incorrect parent.
        # TODO2: Re-evaluate use of TaxonWorks::Vendor::Biodiversity::Result
        names.map! do |name|
          { rank_class: Ranks.lookup(:iczn, name[0]), name: name[1] }
        end
        names.last.merge!({ verbatim_author: get_field_value("scientificNameAuthorship") })

        parent = project.root_taxon_name
        names.each do |name|
          parent = Protonym.create_with(also_create_otu: true).find_or_create_by!(name.merge({ parent: parent }))
        end

        otu = parent.otus.first # TODO: Might require select-and-confirm functionality

        specimen = Specimen.create!({
          total: get_field_value("individualCount") || 1
        })

        specimen.taxon_determinations.create!({
          otu: otu,
          year_made: get_field_value("dateIdentified")
        })

        ### Create collecting event
        end_date = Date.ordinal(get_field_value("year").to_i, get_field_value("endDayOfYear").to_i)

        #TODO: If all attributes are equal assume it is the same event and share it with other specimens?
        CollectingEvent.create!({
          verbatim_date: get_field_value("verbatimEventDate"),
          start_date_year: get_field_value("year"),
          start_date_month: get_field_value("month"),
          start_date_day: get_field_value("day"),
          end_date_year: end_date.year,
          end_date_month: end_date.month,
          end_date_day: end_date.day,
          collection_objects: [specimen],
          with_verbatim_data_georeference: true,
          verbatim_latitude: get_field_value("decimalLatitude"),
          verbatim_longitude: get_field_value("decimalLongitude"),
          verbatim_datum: get_field_value("geodeticDatum"),
          verbatim_locality: get_field_value("locality")
        })

        self.metadata["imported_objects"] = { collection_object: { id: specimen.id } }
        self.status = "Imported"
        save!
      end
    rescue ActiveRecord::RecordInvalid => invalid
      self.status = "Errored"
      self.metadata["error_data"] = {
        messages: invalid.record.errors.messages
      }
    rescue StandardError => e
      raise
      self.status = "Failed"
      self.metadata["error_data"] = {
        exception: {
          message: e.message,
          backtrace: e.backtrace
        }
      }
    ensure
      save!
    end

    self
  end

  private

  def get_fields_mapping
    @fields_mapping ||= import_dataset.metadata["core_headers"].each.with_index.inject({}) { |m, (h, i)| m.merge({ h => i, i => h}) }
  end

  def get_field_value(field_name)
    data_fields[get_fields_mapping[field_name]]&.dig("value")
  end

end
