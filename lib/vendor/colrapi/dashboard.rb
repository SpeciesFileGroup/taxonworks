# Code generated with assistance from Claude (claude-opus-4-6)
module Vendor
  module Colrapi
    module Dashboard

      DATASET_METADATA_EXCLUDED_FIELDS = %w[
        created createdBy modified modifiedBy attempt imported
        lastImportAttempt lastImportState size label citation private platform
      ].freeze

      # @param dataset_id [Integer]
      # @return [Hash]
      #   dataset metadata with internal fields excluded
      def self.dataset_metadata(dataset_id)
        ::Colrapi.dataset(dataset_id: dataset_id.to_i).except(*DATASET_METADATA_EXCLUDED_FIELDS)
      end

      # @param dataset_id [Integer]
      # @return [Hash]
      #   { citation: String, doi: String }
      def self.dataset_citation(dataset_id)
        metadata = ::Colrapi.dataset(dataset_id: dataset_id.to_i)
        { citation: metadata['citation'], doi: metadata['doi'] }
      end

      # @param dataset_id [Integer]
      # @return [Hash]
      #   the most recent finished importer result for the dataset, or empty hash
      def self.dataset_issues(dataset_id)
        response = ::Colrapi.importer(dataset_id_filter: dataset_id.to_i, state: 'finished', limit: 1)
        results = response['result'] || []
        results.any? ? results.first : {}
      end

      # @param query [String]
      # @param limit [Integer]
      # @return [Array]
      #   of { key:, alias:, title: } hashes
      def self.search_datasets(query, limit: 10)
        response = ::Colrapi.dataset(q: query, limit: limit)
        (response['result'] || []).map do |d|
          { key: d['key'], alias: d['alias'], title: d['title'] }
        end
      end

      # @return [Array]
      #   issue vocabulary terms from ChecklistBank
      def self.issue_vocabulary
        ::Colrapi.vocab(term: 'issue')
      end

    end
  end
end
