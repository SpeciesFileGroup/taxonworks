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
    end
  end
end
