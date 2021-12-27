require 'zip'

module Export

  # Exports to a simple format.
  module BasicNomenclature

    def self.export(taxon_name_id)
      t = TaxonName.find(taxon_name_id)

      zip_file_path = "/tmp/_#{SecureRandom.hex(8)}_basic_nomenclature.zip"

      Zip::File.open(zip_file_path, Zip::File::CREATE) do |zipfile|
        zipfile.get_output_stream('names.csv') { |f| f.write generate(t) }
      end

      zip_file_path
    end

    def self.generate(taxon_name)
      CSV.generate(col_sep: "\t") do |csv|

        csv << %w{
          global_id
          order
          infraorder
          superfamily
          family
          subfamily
          genus
          species
          subspecies
          author
          year
          synonyms
        }

        taxon_name.self_and_descendants.that_is_valid.each do |t|
          a = t.ancestor_hash
          syn = t.synonyms.where('taxon_names.id != ?', t.id).collect{|s| s.cached_name_and_author_year }.join('; ')
          csv << [
            t.to_global_id.to_s,
            a['order'],
            a['infraorder'],
            a['superfamily'],
            a['family'],
            a['subfamily'],
            a['genus'],
            a['species'],
            a['subspecies'],
            t.cached_author,
            t.cached_nomenclature_date&.year,
            syn.blank? ? nil : syn,
          ]
        end
      end
    end

    def self.download(taxon_name, request = nil)
      file_path = ::Export::BasicNomenclature.export(taxon_name.id)
      name = "basic_nomenclature_taxon_name_id_#{taxon_name.id}_#{DateTime.now}.zip"

      ::Download::BasicNomenclature.create!(
        name: "Basic nomenclature for #{taxon_name.cached} on #{Time.now}.",
        description: 'A zip file containing a simple CSV export of nomenclature.',
        filename: name,
        source_file_path: file_path,
        request: request,
        expires: 2.days.from_now
      )
    end

    def self.download_async(taxon_name, request = nil)
      name = "basic_nomenclature_taxon_name_id_#{taxon_name.id}_#{DateTime.now}.zip"

      download = ::Download::BasicNomenclature.create!(
        name: "Basic nomenclature for #{taxon_name.cached} on #{Time.now}.",
        description: 'A zip file containing a simple CSV export of nomenclature.',
        filename: name,
        request: request,
        expires: 2.days.from_now
     )

      BasicNomenclatureCreateDownloadJob.perform_later(taxon_name, download)

      download
    end

  end
end
