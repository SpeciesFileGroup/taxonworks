module Vendor

  # A middle-layer wrapper between Hookkaido and TaxonWorks, constrained to the
  # Environment Ontology (ENVO). AssertedEnvironment terms are ENVO-only by
  # design (see AssertedEnvironment), so, unlike AnatomicalPart's use of
  # Hookkaido, the ontology here is never caller-supplied.
  module Envo
    ONTOLOGY = 'envo'.freeze

    # ENVO terms are published as OBO Library PURLs, e.g.
    #   http://purl.obolibrary.org/obo/ENVO_00002007
    URI_PATTERN = %r{\Ahttp://purl\.obolibrary\.org/obo/ENVO_\d+\z}

    # @param term [String] search string to match against ENVO labels/synonyms
    # @return [Hash] { results:, page:, per:, total: }
    def self.search(term, per: 25, page: 1)
      ::Hookkaido.search(term, ontologies: [ONTOLOGY], per:, page:)
    end

    # @param uri [String, nil]
    # @return [Boolean] true if uri is a well-formed ENVO OBO Library PURL
    def self.valid_uri?(uri)
      uri.present? && URI_PATTERN.match?(uri)
    end
  end
end
