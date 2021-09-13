require 'csl/styles'

module TaxonWorks
  module Vendor

    module BibtexRuby

      def self.bibliography(sources)
        b = BibTeX::Bibliography.new
        sources.each do |s|
          next unless s.is_bibtex?
          e = s.to_bibtex
          e.year = '0000' if e.year.blank? # cludge to fix render problem with year
          b.add(e)
        end
        b
      end

      # @return Array
      #   of styled sources
      def self.styled(sources = [], style_id = 'http://www.zotero.org/styles/vancouver')
        return [] unless s = ::CSL_STYLES[style_id]
        sources.collect{|b| b.render_with_style(style_id) }.sort
      end

    end
  end
end
