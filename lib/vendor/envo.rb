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
      payload = ::Hookkaido.search(term, ontologies: [ONTOLOGY], per:, page:)

      # OLS's `ontology: envo` scope includes terms merely referenced inside
      # ENVO's OWL graph (e.g. imported CHEBI/PATO classes), not only terms
      # minted under the ENVO_ namespace - filter to real ENVO PURLs so we
      # never offer a result AssertedEnvironment's own validation would reject.
      payload.merge(results: payload[:results].select { |r| valid_uri?(r[:iri]) })
    rescue => e
      Rails.logger.warn "Vendor::Envo.search error: #{e.message}"
      { results: [], page:, per:, total: 0 }
    end

    # @param uri [String, nil]
    # @return [Boolean] true if uri is a well-formed ENVO OBO Library PURL
    def self.valid_uri?(uri)
      uri.present? && URI_PATTERN.match?(uri)
    end

    # PURL_PREFIX is fixed by URI_PATTERN (and enforced by valid_uri? on every
    # AssertedEnvironment#uri), so the local id is always the final path
    # segment - safe to display in place of the full PURL.
    # @param uri [String, nil] a well-formed ENVO OBO Library PURL
    # @return [String, nil] the local id, e.g. "ENVO_00002007"
    def self.local_id(uri)
      uri&.split('/')&.last
    end
  end
end
