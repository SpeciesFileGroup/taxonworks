require 'zip'
require 'yaml'

module Export

  # Exports to the Catalog of Life in the new "coldp" format.
  # http://api.col.plus/datapackage
  #
  # * write tests to check for coverage (missing methods)
  # * Update all files formats to use tabs
  # * Pending handling of both BibTeX and Verbatim
  module Coldp

    FILETYPES = %w{Description Name Synonym VernacularName}.freeze

    # @return [Scope]
    #  A full set of valid only Otus (= Taxa in CoLDP) that are to be sent.
    #  !! At present no OTU with a `name` is sent.  In the future this may
    #  !! need to change.
    def self.otus(otu_id)
      o = ::Otu.find(otu_id)
      return ::Otu.none if o.taxon_name_id.nil?

      Otu.joins(taxon_name: [:ancestor_hierarchies])
        .where('taxon_name_hierarchies.ancestor_id = ?', o.taxon_name_id)
        .where(taxon_name_id: TaxonName.that_is_valid)
        .where('(otus.name IS NULL) OR (otus.name = taxon_names.cached)')
    end

    def self.export(otu_id, prefer_unlabelled_otus: true)
      otus = otus(otu_id)
      Current.project_id = Otu.find(otu_id).project_id

      # source_id: [csv_array]
      ref_csv = {}

      # TODO: This will likely have to change, it is renamed on serving the file.
      zip_file_path = "/tmp/_#{SecureRandom.hex(8)}_coldp.zip"

      metadata_path = Zaru::sanitize!("/tmp/#{::Project.find(Current.project_id).name}_#{DateTime.now}_metadata.yaml").gsub(' ', '_').downcase
      version = Taxonworks::VERSION
      if Settings.sandbox_mode?
        version = Settings.sandbox_commit_sha
      end
      metadata = {"title" =>::Project.find(Current.project_id).name,
                  "version" => version,
                  "issued" => DateTime.now.strftime('%Y-%m-%d'),
      }
      metadata_file = Tempfile.new(metadata_path)
      metadata_file.write(metadata.to_yaml)
      metadata_file.close

      Zip::File.open(zip_file_path, Zip::File::CREATE) do |zipfile|
        (FILETYPES - ['Name']).each do |ft|
          m = "Export::Coldp::Files::#{ft}".safe_constantize
          zipfile.get_output_stream("#{ft}.csv") { |f| f.write m.generate(otus, ref_csv) }
        end

        zipfile.get_output_stream('Name.csv') { |f| f.write Export::Coldp::Files::Name.generate(Otu.find(otu_id), ref_csv) }
        zipfile.get_output_stream('Taxon.csv') do |f|
          f.write Export::Coldp::Files::Taxon.generate(otus, otu_id, ref_csv, prefer_unlabelled_otus: prefer_unlabelled_otus)
        end

        # Sort the refs by full citation string
        sorted_refs = ref_csv.values.sort{|a,b| a[1] <=> b[1]}

        d = CSV.generate(col_sep: "\t") do |csv|
          csv << %w{ID citation	doi} # author year source details
          sorted_refs.each do |r|
            csv << r
          end
        end

        zipfile.get_output_stream('References.csv') { |f| f.write d }
        zipfile.add("metadata.yaml", metadata_file.path)
      end

      zip_file_path
    end

    def self.filename(otu)
      Zaru::sanitize!("#{::Project.find(Current.project_id).name}_coldp_otu_id_#{otu.id}_#{DateTime.now}.zip").gsub(' ', '_').downcase
    end

    def self.download(otu, request = nil, prefer_unlabelled_otus: true)
      file_path = ::Export::Coldp.export(
        otu.id,
        prefer_unlabelled_otus: prefer_unlabelled_otus
      )
      name = "coldp_otu_id_#{otu.id}_#{DateTime.now}.zip"

      ::Download::Coldp.create!(
        name: "ColDP Download for #{otu.otu_name} on #{Time.now}.",
        description: 'A zip file containing CoLDP formatted data.',
        filename: filename(otu),
        source_file_path: file_path,
        request: request,
        expires: 2.days.from_now
      )
    end

    def self.download_async(otu, request = nil, prefer_unlabelled_otus: true)
      download = ::Download::Coldp.create!(
        name: "ColDP Download for #{otu.otu_name} on #{Time.now}.",
        description: 'A zip file containing CoLDP formatted data.',
        filename: filename(otu),
        request: request,
        expires: 2.days.from_now
      )

      ColdpCreateDownloadJob.perform_later(otu, download, prefer_unlabelled_otus: prefer_unlabelled_otus)

      download
    end


    # TODO - perhaps a utilities file --

    # @return [Boolean]
    #  `true` if no parens in `cached_author_year`
    #  `false` if parens in `cached_author_year`
    def self.original_field(taxon_name)
      (taxon_name.type == 'Protonym') && taxon_name.is_original_name?
    end

    # @param taxon_name [a valid Protonym or a Combination]
    #   see also exclusion of OTUs/Names based on Ranks not handled
    def self.basionym_id(taxon_name)
      if taxon_name.type == 'Protonym'
        taxon_name.reified_id
      elsif taxon_name.type == 'Combination'
        taxon_name.protonyms.last.reified_id
      else
        nil
      end
    end

    # Replicate TaxonName.refified_id without having to use AR
    def self.reified_id(taxon_name_id, cached, cached_original_combination)
      # Protonym#has_alternate_original?
      if cached_original_combination && (cached != cached_original_combination)
        taxon_name_id.to_s + '-' + Digest::MD5.hexdigest(cached_original_combination)
      else
        taxon_name_id
      end
    end

    # Reification spec
    # Duplicate Combination check -> is the Combination in question already represented int he current *classification*
  end
end
