require 'csl/styles'

module TaxonWorks
  module Vendor

    module BibtexRuby

      # TODO: Might have to move to constant/init
      # !! this will add 2-3 seconds to boot perhaps !!
      styles = CSL::Style.list.map { |id| CSL::Style.load id }.reject { |s| s.bibliography.nil? }
      CSL_STYLES = styles.inject({}){|h, a| h.merge(a.id => a.title)}.freeze

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
