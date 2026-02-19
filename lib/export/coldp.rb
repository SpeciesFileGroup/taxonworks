require 'zip'
require 'yaml'

# To generate a file on the console:
#
#   Current.user_id = ; Current.project_id = ;
#   o = Otu.find()
#   d = ::Export::Coldp.download(o, 'foo')
#   d.file_path
#
#   Current.user_id = ; Current.project_id = ;  o = Otu.find()  d = ::Export::Coldp.download(o, 'foo'); 
#
module Export

  # Exports to the Catalog of Life in the new "coldp" format.
  # http://api.col.plus/datapackage
  #
  # TODO:
  #  * Resolve missing/something Refs
  #  * Resolve duplicate/extra names?!
  #  * AcceptedName missing for Synonyms
  #
  # * Status of Distribution  - always present in code, what's the positive assertion in 'status'
  # * Ensure all joins are Pipes
  # * Review/remove/update/add tests to check for coverage
  # * Pending handling of both BibTeX and Verbatim
  # * Document what Coldp *expects*, in particular inferred combionations
  # Optimizations possible:
  # * Eliminate next checks (though they are currently fine) by calculating in SQL
  module Coldp

    class << self
      # @return [Array] used to pass along inference at the
      # name.tsv level to the synonym.tsv level. Could be replaced
      # when Combination can use SQL to determine the rank of the
      # name Combination applies to.  !! Should just cache this.
      attr_accessor :skipped_combinations
    end

    # give it a default value
    @skipped_combinations = []

    # A hash lookup to find Notes in memory
    attr_accessor :remarks

    def remarks
      @remarks ||= []
      @remarks
    end

    def self.remarks=(values)
      @remarks = values
    end


    # Presently stubbed but excluded pending
    # significant use.
    #
    #  TaxonConceptRelation
    #
    FILETYPES = %w{
      Distribution
      Name
      NameRelation
      References
      SpeciesInteraction
      Synonym
      Taxon
      TypeMaterial
      VernacularName
    }.freeze

    # @return [Scope]
    #  A full set of valid only OTUs (= Taxa in CoLDP) that are to be sent.
    #
    #  !! At present no OTU with a `name` is sent. In the future this may need to change.
    #
    #  !?! - not true !! No synonym TaxonName is sent if they don't have an OTU
    #
    #  This is presently not scoping Names.csv. That's probably OK.
    #
    # TODO: Lock step this with Names
    def self.otus(otu_id)
      o = ::Otu.find(otu_id)
      return ::Otu.none if o.taxon_name_id.nil?

      Otu.joins(taxon_name: [:ancestor_hierarchies])
        .where(taxon_names: {cached_is_valid: true} )
        .where('taxon_name_hierarchies.ancestor_id = ?', o.taxon_name_id)
        .where('(otus.name IS NULL) OR (otus.name = taxon_names.cached)') # !! Union does not make this faster
    end

    # TODO: find by IRI, not predicate_id so that we can unify the vocabulary.
    # Accessed per file type
    def self.get_remarks(scope, predicate_id)
      c = DataAttribute.with(invalid_names: scope.select('taxon_names.id invalid_id'))
        .joins("JOIN invalid_names ON invalid_names.invalid_id = data_attributes.attribute_subject_id AND data_attributes.attribute_subject_type = 'TaxonName'")
        .select("data_attributes.attribute_subject_id, STRING_AGG(data_attributes.value, '|') AS values")
        .where(data_attributes: {controlled_vocabulary_term_id: predicate_id})
        .group('data_attributes.attribute_subject_id')

      ApplicationRecord.connection.execute(c.to_sql).to_a
    end

    def self.project_members(project_id)
      project_members = {}
      ProjectMember.eager_load(:user).where(project_id:).each do |pm|
        if pm.user.orcid.nil?
          project_members[pm.user_id] = pm.user.name
        else
          project_members[pm.user_id] = pm.user.orcid
        end
      end
      project_members
    end

    def self.modified(updated_at)
      if updated_at.nil?
        ''
      else
        updated_at&.iso8601
      end
    end

    def self.modified_by(updated_by_id, project_members)
      project_members[updated_by_id]
    end

    # TODO: Move to Strings::Utilities
    def self.sanitize_remarks(id)
      return nil if @remarks.blank?
      v = @remarks.bsearch{|i| i['attribute_subject_id'] >= id}
      return nil if v['attribute_subject_id'] != id # bsearch finds >=
      return v['values']&.gsub('\r\n', ' ')&.gsub('\n', ' ')&.gsub('\t', ' ')&.gsub(/[ ]+/, ' ')   if v
      nil
    end

    # Return path to the data itself
    #
    # TODO: mode: taxon_name_proxy
    #
    def self.export(otu_id, prefer_unlabelled_otus: true)
      otus = otus(otu_id)

      # source_id: [csv_array]
      ref_tsv = {}

      otu = ::Otu.find(otu_id)

      # Check for a clb_dataset_id identifier
      # TODO: Document this setup process.  Include it in Project settings likely. Remember > 1 checklist can emerge from a project.
      ns = Namespace.find_by(institution: 'ChecklistBank', name: 'clb_dataset_id')
      clb_dataset_id = otu.identifiers.where(namespace_id: ns.id)&.first&.identifier unless ns.nil?

      project = ::Project.find(otu.project_id)
      project_id = project.id

      project_members = project_members(project.id)
      feedback_url = project[:data_curation_issue_tracker_url] unless project[:data_curation_issue_tracker_url].nil?

      # TODO: This will likely have to change, it is renamed on serving the file.
      zip_file_path = "/tmp/_#{SecureRandom.hex(8)}_coldp.zip"

      metadata_path = Zaru::sanitize!("/tmp/#{project.name}_#{DateTime.now}_metadata.yaml").gsub(' ', '_').downcase
      version = TaxonWorks::VERSION
      if Settings.sandbox_mode?
        version = Settings.sandbox_commit_sha
      end

      # We lose the ability to maintain title in TW but until we can model metadata in TW,
      #   it seems desirable because there's a lot of TW vs CLB title mismatches
      if clb_dataset_id.nil?
        metadata = {
          'title' => project.name,
          'issued' => DateTime.now.strftime('%Y-%m-%d'),
          'version' => DateTime.now.strftime('%b %Y'),
          'feedbackUrl' => feedback_url
        }
      else
        metadata = Colrapi.dataset(dataset_id: clb_dataset_id) unless clb_dataset_id.nil?

        # remove fields maintained by ChecklistBank or TW
        exclude_fields = %w[created createdBy modified modifiedBy attempt imported lastImportAttempt lastImportState size label citation private platform]
        metadata = metadata.except(*exclude_fields)

        # put feedbackUrl before the contact email in the metadata file to encourage use of the issue tracker
        reordered_metadata = {}
        metadata.each do |key, value|
          if key == 'contact'
            reordered_metadata['feedbackUrl'] = feedback_url
          end
          reordered_metadata[key] = value
        end
        metadata = reordered_metadata
      end

      metadata['issued'] = DateTime.now.strftime('%Y-%m-%d')
      metadata['version'] = DateTime.now.strftime('%b %Y')

      platform = {
        'name' => 'TaxonWorks',
        'alias' => 'TW',
        'version' => version
      }
      metadata['platform'] = platform

      metadata_file = Tempfile.new(metadata_path)
      metadata_file.write(metadata.to_yaml)
      metadata_file.close

      Zip::File.open(zip_file_path, create: true) do |zipfile|

       zipfile.get_output_stream('Name.tsv') { |f| f.write Export::Coldp::Files::Name.generate(otu, project_members, ref_tsv) }
       zipfile.get_output_stream('NameRelation.tsv') { |f| f.write Export::Coldp::Files::NameRelation.generate(otu, project_members, ref_tsv) }
       zipfile.get_output_stream('TypeMaterial.tsv') { |f| f.write Export::Coldp::Files::TypeMaterial.generate(otu, project_members, ref_tsv) }

       zipfile.get_output_stream('Synonym.tsv') { |f| f.write Export::Coldp::Files::Synonym.generate(otu, otus, project_members, ref_tsv) }
       zipfile.get_output_stream('Taxon.tsv') { |f| f.write Export::Coldp::Files::Taxon.generate(otu, otus, project_members, ref_tsv, prefer_unlabelled_otus) }

       (FILETYPES - %w{Name NameRelation TypeMaterial Synonym Taxon References}).each do |ft|
         puts ft
         m = "Export::Coldp::Files::#{ft}".safe_constantize
         zipfile.get_output_stream("#{ft}.tsv") { |f| f.write m.generate(otus, project_members, ref_tsv) }
       end

        # Sort the refs by full citation string
        sorted_refs = ref_tsv.values.sort{|a,b| a[1] <=> b[1]}

        d = ::CSV.generate(col_sep: "\t") do |tsv|
          tsv << %w{ID citation doi modified modifiedBy} # Consider: author year source details
          sorted_refs.each do |r|
            tsv << r
          end
        end

        zipfile.get_output_stream('References.tsv') { |f| f.write d }

        zipfile.add('metadata.yaml', metadata_file.path) # TODO: consider isolating Files.metadata logic
      end

      zip_file_path
    end

    def self.filename(otu)
      Zaru::sanitize!("#{::Project.find(otu.project_id).name}_coldp_otu_id_#{otu.id}_#{DateTime.now}.zip").gsub(' ', '_').downcase
    end

    def self.download(otu, request = nil, prefer_unlabelled_otus: true)
      file_path = ::Export::Coldp.export(
        otu.id,
        prefer_unlabelled_otus:
      )
      name = "coldp_otu_id_#{otu.id}_#{DateTime.now}.zip"

      ::Download::Coldp.create!(
        name: "ColDP Download for #{otu.otu_name} on #{Time.now}.",
        description: 'A zip file containing CoLDP formatted data.',
        filename: filename(otu),
        source_file_path: file_path,
        request:,
        expires: 5.days.from_now
      )
    end

    def self.download_async(otu, request = nil, prefer_unlabelled_otus: true)
      download = ::Download::Coldp.create!(
        name: "ColDP Download for #{otu.otu_name} on #{Time.now}.",
        description: 'A zip file containing CoLDP formatted data.',
        filename: filename(otu),
        request:,
        expires: 5.days.from_now
      )

      ColdpCreateDownloadJob.perform_later(otu, download, prefer_unlabelled_otus:)

      download
    end

    # TODO - perhaps a utilities file --

    # Doesn't exist in ColDP
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

    # Replicate TaxonName.refified_id.  This is here because we pluck to arrays in the
    # dump. It's janky.
    # TODO: try to eliminate, at minimum test for consistency?
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

    # Iterates the manifest used by Name
    # !! includes only id
    def self.all_names(otu)
      names = []
      Export::Coldp::Files::Name::MANIFEST.each do |m|
        names.push TaxonName.select(:id).from( Export::Coldp::Files::Name.send(m, otu))
      end

      all_names = ::Queries.union(TaxonName, names)
    end

  end
end
