module TaxonWorks
  module Vendor

    # A middle-layer wrapper between Serrano and TaxonWorks
    module Serrano
      CUTOFF = 50.0

      # @return [Float]
      def self.cutoff
        CUTOFF
      end

      class CrossRefLaTeX
        include Singleton

        def apply(value)
          if value.is_a? String
            value = value.gsub(/\$\\less\$\/?\w+\$\\greater\$/,
              '$\less$i$\greater$' => '<i>', '$\less$/i$\greater$' => '</i>',
              '$\less$em$\greater$' => '<i>', '$\less$/em$\greater$' => '</i>' # Some times <em> is used for scientific names, making sense to translate to TW-supported <i>
            )
          end
          ::LaTeX.decode(value)
        end
      end

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
        citation&.strip!
        return false if citation.length < 6
        # check string encoding, if not UTF-8, check if compatible with UTF-8,
        # if so convert to UTF-8 and parse with latex, else use type verbatim
        a = get_bibtex_string(citation, 'bibtex')
        b = ::Utilities::Strings.encode_with_utf8(a) if a
        if b
          bibtex = Source::Bibtex.new_from_bibtex(BibTeX::Bibliography.parse(b, filter: CrossRefLaTeX.instance).first)
          citeproc = get_bibtex_string(citation, 'citeproc')
          bibtex_from_citproc(citeproc, bibtex)
        else
          Source::Verbatim.new(verbatim: a ? a : citation)
        end
      end

      # @return [String, nil] ; format == 'bibtex' or 'citeproc'
      def self.get_bibtex_string(citation, format = 'bibtex')
        begin
          # Convert citation to DOI if it isn't already
          if !citation_is_valid_doi?(citation)
            # First item should be the one with highest score/relevance: https://github.com/CrossRef/rest-api-doc#sort-order
            res = ::Serrano.works(query: citation, limit: 1)&.dig("message", "items")&.first
            # citation = Serrano.works(query: citation)&.dig("message", "items")&.max_by { |i| i["score"] }&.dig("DOI") unless citation_is_valid_doi?(citation)

            score = res&.dig("score") || -1.0
            citation = (score >= CUTOFF) ? res&.dig("DOI") : nil
          end

          if format == 'bibtex'
            bibtex = ::Serrano.content_negotiation(ids: unurize_doi(citation), format: "bibtex") unless citation.nil?
            return bibtex =~ /^\s*@/ ? bibtex : nil
          elsif format == 'citeproc'
            citeproc = ::Serrano.content_negotiation(ids: unurize_doi(citation), format: "citeproc-json") unless citation.nil?
            return citeproc
          else
            return nil
          end
        rescue
          return nil
        end
      end

      def self.bibtex_from_citproc(c, b)
        return nil if c.nil? || b.nil?
        c = JSON.parse(c)

        b[:address] = ::Utilities::Strings.encode_with_utf8(c['address']) unless c['address'].blank?
        #b[:author]
        b[:booktitle] = ::Utilities::Strings.encode_with_utf8(c['booktitle']) unless c['booktitle'].blank?
        b[:chapter] = c['chapter'] unless c['chapter'].blank?
        b[:edition] = c['edition'] unless c['edition'].blank?
        #b[:editor]
        b[:howpublished] = ::Utilities::Strings.encode_with_utf8(c['how-published']) unless c['how-published'].blank?
        b[:institution] = ::Utilities::Strings.encode_with_utf8(c['institution']) unless c['institution'].blank?
        b[:journal] = ::Utilities::Strings.encode_with_utf8(c['container-title']) unless c['container-title'].blank?
        #b[:month]
        b[:note] = ::Utilities::Strings.encode_with_utf8(c['note']) unless c['note'].blank?
        #b[:number] = c['number'] unless c['volume'].blank?
        b[:organization] = ::Utilities::Strings.encode_with_utf8(c['organization']) unless c['organization'].blank?
        b[:pages] = c['page'] unless c['page'].blank?
        b[:publisher] = ::Utilities::Strings.encode_with_utf8(c['publisher']) unless c['publisher'].blank?
        b[:school] = ::Utilities::Strings.encode_with_utf8(c['school']) unless c['school'].blank?
        b[:series] = c['series'] unless c['series'].blank?
        #b[:title] = c['title']
        # b[:typeb]  # "Source::Bibtex"
        #b[:volume] = c['volume'] unless c['volume'].blank?
        #b[:doi] = c['DOI']
        unless c['abstract'].blank?
          b[:abstract] = ::Utilities::Strings.encode_with_utf8(c['abstract']).
            gsub('</jats:p>', '').
            gsub('<jats:p>', '').
            gsub('</jats:italic>', '</i>').
            gsub('<jats:italic>', '<i>').
            gsub('</jats:bold>', '</b>').
            gsub('<jats:bold>', '<b>')
        end
        b[:copyright] = c['copyright'] unless c['copyright'].blank?
        #b[:bibtex_type] = c['type'] unless c['type'].blank?
        b[:day]  = c['issued']['date-parts'][0][2] if c['issued'] && c['issued']['date-parts'] && c['issued']['date-parts'][0] && c['issued']['date-parts'][0][2]
        b[:year] = c['issued']['date-parts'][0][0] if c['issued'] && c['issued']['date-parts'] && c['issued']['date-parts'][0] && c['issued']['date-parts'][0][0]
        b[:isbn] = c['ISBN'].first unless c['ISBN'].blank?
        b[:issn] = c['ISSN'].first unless c['ISSN'].blank?
        #b[:translator]
        #b[:url]
        b[:serial_id] = Serial.where(name: b[:journal]).first.try(:id) unless b[:journal].blank?
        b
      end

      # @return [String]
      def self.unurize_doi(doi)
        doi = doi.strip

        if matches = doi.match(/https?:\/\/[^\/]+\/(.*)/)
          matches[1]
        else
          doi
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
