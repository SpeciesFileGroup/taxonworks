require 'ref2bibtex'

module TaxonWorks
  module Vendor

    # A middle-layer wrapper between Sqed and TaxonWorks
    module Ref2bibtex

      # Create a new Source instance from a full text citatation.
      # By default, try to detect and clean up a DOI (with/out "http" preamble)
      # Then try to resolve the citation against Crossref
      # Use the returned bibtex to populate the object if it successfully resolves.
      #
      # Once created followup with .create_related_people_and_roles to create related people.
      #
      # @param citation [String] the full text of the citation, or DOI to convert

      # TODO: attempt to extract DOI from full string
      #
      # @return [Source::BibTex.new] a new instance
      # @return [Source::Verbatim.new] a new instance
      # @return [false]
      # Four possible paths:
      # 1)  citation.
      # 2)  citation which includes a doi.
      # 3)  naked doi, e.g., '10.3897/zookeys.20.205'.
      # 4)  doi with preamble, e.g., 'http://dx.doi.org/10.3897/zookeys.20.205' or
      #                              'https://doi.org/10.3897/zookeys.20.205'.
      def self.new_from_citation(citation: nil)
        return false if citation.length < 6

        # check string encoding, if not UTF-8, check if compatible with UTF-8,
        # if so convert to UTF-8 and parse with latex, else use type verbatim
        a = get_bibtex_string(citation) 
        b = ::Utilities::Strings.encode_with_utf8(a) if a

        if b
          Source::Bibtex.new_from_bibtex(
            BibTeX.parse(b).convert(:latex).first
          )
        else
          Source::Verbatim.new(verbatim: a ? a : citation)
        end
      end

      # @return [String, nil]
      def self.get_bibtex_string(citation)
        begin
          if citation_is_valid_doi?(citation)
            a = urize_doi(citation)
            ::Ref2bibtex.get_bibtex(a) 
          else
            ::Ref2bibtex.get(citation) 
          end
        rescue Net::HTTPServerException
          return nil
        end
      end

      # @return [String]
      def self.urize_doi(doi)
        if doi =~ /http/
          doi
        else
          'https://doi.org/' + doi
        end
      end

      # @return Boolean
      #   use our global identifier class to determined if value is DOI
      #   this isn't super robust, but maybe OK
      def self.citation_is_valid_doi?(citation)
        doi = Identifier::Global::Doi.new(identifier: citation)
        doi.valid?
        !doi.errors.has_key?(:identifier)
      end 

    end
  end
end
