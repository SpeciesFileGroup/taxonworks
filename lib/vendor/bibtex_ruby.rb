require 'csl/styles'
require 'namecase'

module TaxonWorks
  module Vendor
    module BibtexRuby

      TAXONWORKS_STYLE_ROOT = File.expand_path(Rails.root.to_s + '/lib/vendor/styles/')
      CSL_STYLE_ROOT = CSL::Style.root

      # @return a CSL::Style object
      # Searches first through CSL/Styles
      def self.get_style(style)
        return nil if style.nil?
        begin
          if s = CSL::Style.load(style)
            return s
          end
        rescue CSL::ParseError
        end

        toggle_style_root # set to TaxonWorks path

        begin
          if s = CSL::Style.load(style)
            return s
          end
        rescue CSL::ParseError
          return nil
        ensure
          toggle_style_root # set it back to rubygems
        end
      end

      def self.namecase_bibtex_entry(bibtex_entry)
        bibtex_entry.parse_names
        bibtex_entry.names.each do |n|
          n.first = NameCase(n.first) if n.first
          n.last = NameCase(n.last) if n.last
          #n.prefix = NameCase(n.prefix) if n.prefix
          #n.suffix = NameCase(n.suffix) if n.suffix
        end
        bibtex_entry
      end

      def self.bibliography(sources)
        b = BibTeX::Bibliography.new
        sources.each do |s|
          next unless s.is_bibtex?
          e = s.to_bibtex
          e.year = '0000' if (e.year.nil? || e.year == '')
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

      private

      def self.toggle_style_root
        if CSL::Style.root == CSL_STYLE_ROOT
          CSL::Style.root = TAXONWORKS_STYLE_ROOT
        else
          CSL::Style.root = CSL_STYLE_ROOT
        end
      end

    end
  end
end
