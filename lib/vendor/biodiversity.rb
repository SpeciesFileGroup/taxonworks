module TaxonWorks
  module Vendor

    # Wraps the biodiversity gem (https://github.com/GlobalNamesArchitecture/biodiversity)
    # Links parsed string results to Protonyms/Combinations in TaxonWorks.
    #   a = TaxonWorks::Vendor::Biodiversity::Result.new 
    #   a.name = 'Aus bus'
    #   a.parse
    #
    module Biodiversity
      
      RANK_MAP = {
        genus: :uninomial, #  :genus,
        subgenus: :infragenericEpithet,
        species: :specificEpithet,
        subspecies: :infraspecificEpithets,
        variety: :infraspecificEpithets,
        form: :infraspecificEpithets
      }.freeze

      class Result
        # query string
        attr_accessor :name

        # how to match
        #   `ranked`: return names at that queried rank only (e.g. only match a subgenus to rank subgenus
        #   `groups`: return names at Group level (species or genus), i.e. a subgenus name in query will match genus OR subgenus in database
        attr_accessor :mode

        # project to query against
        attr_accessor :project_id

        # one of :iczn, :icn, :icnp
        attr_accessor :nomenclature_code

        # the result of a ScientificNameParser parse
        attr_accessor :parse_result

        # a summarized result, used to render JSON
        #   {
        #     protonyms: { genus: [ @protonym1, ...], ... }
        #     parse: { genus:  'Aus', species: 'bus', ...}
        #   }
        # Hash of rank => [Protonyms] like { genus: [<#>, <#>] }
        attr_reader :result

        # @return [String] the bit after ` in `
        attr_reader :citation

        # @return [Boolean] 
        #   whether or not the query string was succesfully parsed
        attr_reader :parseable

        # @return [Hash]
        #   a memoized result of the matching TW protonyms per rank
        attr_reader :protonym_result

        # @return [Combination]
        #   a memoized result of disambiguated_combination
        attr_reader :disambiguated_combination

        # @return [Combination]
        #   a memoized combiantion with only unambiguous elements 
        attr_reader :combination

       def initialize(query_string: nil, project_id: nil, code: :iczn, match_mode: :groups)
          @project_id = project_id
          @name = query_string
          @nomenclature_code = code
          @mode = match_mode

          parse if !query_string.blank?
        end

        # @return [@parse_result]
        #   a Biodiversity name parser result
        def parse
          @combination = nil
          @disambiguated_combination = nil

          n, @citation = preparse

          begin
            @parse_result ||= ::Biodiversity::Parser.parse(n)
          rescue NoMethodError => e
            case e.message
            when /canonical/
              @parseable = false 
            else
              raise
            end
          end

          @parse_result[:scientificName] = parse_result[:normalized]
          @parse_result
        end

        # @return [Boolean]
        def parseable
          @parseable = parse_result[:parsed] && parse_result[:tail].blank? if @parseable.nil?
          @parseable 
        end

        # @return [Array]
        #  TODO: deprecate
        def preparse
          name.split(' in ')
        end

        # @return [Hash]
        def detail
          parse_result[:details] || {}
        end

        # @return [String, nil]
        def genus
          parse_result[:words]&.detect { |w| %{UNINOMIAL GENUS}.include?(w[:wordType]) }&.dig(:normalized)
        end

        # @return [String, nil] 
        def subgenus
          (parse_result[:words] || [])[1..]&.detect { |w| %{UNINOMIAL INFRA_GENUS}.include?(w[:wordType]) }&.dig(:normalized)
        end

        # @return [String, nil]
        def species
          parse_result[:words]&.detect { |w| 'SPECIES' == w[:wordType] }&.dig(:normalized)
        end

        # @return [String, nil]
        def subspecies
          infraspecies(nil)
        end

        # @return [String, nil]
        def variety
          infraspecies('var.')
        end

        # @return [String, nil]
        def form
          infraspecies('f.')
        end

        # @return [String, nil]
        def infraspecies(biodiversity_rank)
          detail.dig(:infraSpecies, :infraSpecies)&.detect { |e| e[:rank] == biodiversity_rank }&.dig(:value)
        end

        # @return [Integer]
        #   the total monomials in the epithet
        def name_count 
          (detail[detail.keys.first].keys - [:authorship]).count
        end

        # @return [Symbol, nil] like `:genus`
        def finest_rank
          RANK_MAP.keys.reverse.each do |k|
            return k if send(k)
          end
          nil
        end

        # @return [Hash, nil]
        #   the Biodiversity authorship hash
        def authorship
          parse_result.dig(:authorship, :originalAuth)
        end

        # @return [String, nil]
        def author
          if a = authorship
            Utilities::Strings.authorship_sentence(a[:authors])
          else
            nil
          end
        end

        def author_year
          [author, year].compact.join(', ')
        end

        # @return [String, nil]
        def year
          if a = authorship
            return a.dig(:year, :year)
          end
        end

        # return only references to ambiguous protonyms
        #
        # Parse 'form' 
        # Parse 'parse 'Var" 

        # @return [Boolean]
        #   true if for each parsed piece of there name there is 1 and only 1 result
        def is_unambiguous?
          RANK_MAP.each_key do |r|
            if !send(r).nil?
              return false unless !send(r).nil? && !unambiguous_at?(r).nil?
            end
          end
          true
        end

        # @return [Boolean]
        def is_authored?
          author_year.size > 0
        end

        # @return [Protonym, nil]
        #   true if there is a single matching result or nominotypical subs
        # @param rank [Symbol] like `:genus` or `:species`
        def unambiguous_at?(rank)
          return protonym_result[rank].first if protonym_result[rank].size == 1
          if protonym_result[rank].size == 2
            n1 = protonym_result[rank].first
            n2 = protonym_result[rank].last
            return n2 if n2.nominotypical_sub_of?(n1) 
            return n1 if n1.nominotypical_sub_of?(n2) 
          end
          nil 
        end

        # @return [Array]
        #   the ranks, as symbols, at which there are multiple (>1) Protonym matches
        #   !! subtly different than unambiguous_at, probably should use that?!
        def ambiguous_ranks
          a = [ ]
          protonym_result.each do |k, v|
            a.push k if v.count > 1
          end
          a 
        end

        # @return [Combination]
        # @param target_protonym_ids [Hash] like like `{genus: 123, species: 345}`
        #   Given a targeted list of ids checks to see if
        #      a) there is an *ambiguous* result at the rank AND
        #      b) there is a Protonym with the id provided in the ambiguous result
        #   If a and b are both true then the combination once ambiguous result is set to the id provided in targeted_protonym_ids
        def disambiguate_combination(target_protonym_ids = {})
          return nil unless target_protonym_ids.any?
          c = combination
          b = ambiguous_ranks

          target_protonym_ids.each do |rank, id|
            if b.include?(rank)
              c.send("#{rank}_id=", id) if protonym_result[rank].map(&:id).include?(id)
            end
          end
          @disambiguated_combination = c
        end

        # @return [ String, false ]
        #   a wrapper on string returning methods
        # @param rank [Symbol, String] 
        #   rank is one of `genus`, `subgenus`, `species, `subspecies`, `variety`, `form`
        def string(rank = nil)
          send(rank)
        end

        # @return [Scope]
        # @param rank [Symbol] like `:genus` or `:species`
        def basic_scope(rank)
          Protonym.where(
            project_id: project_id,
            name: string(rank)
          )
        end

        # @return [Scope]
        # @param rank [Symbol] like `:genus` or `:species`
        def protonyms(rank)
          case mode
          when :ranked
            ranked_protonyms(rank)
          when :groups
            grouped_protonyms(rank)
          else
            Protonym.none
          end
        end

        # @return [Scope]
        #    Protonyms at a given rank
        def ranked_protonyms(rank)
          basic_scope(rank).where(rank_class: Ranks.lookup(nomenclature_code, rank))
        end

        # @return [Scope]
        # @param rank [Symbol] like `:genus` or `:species`
        #   Protonyms grouped by nomenclatural group, for a rank
        def grouped_protonyms(rank)
          s = case rank
              when :genus, :subgenus
                basic_scope(rank).is_genus_group
              when :species, :subspecies, :variety, :form
                basic_scope(rank).is_species_group
              else
                Protonym.none
              end

          (is_authored? && finest_rank == rank) ? scope_to_author_year(s) : s
        end

        # @return [Scope]
        #  if there is an exact author year match scope it to that match, otherwise
        #     ignore the author year
        def scope_to_author_year(scope)
          t = scope.where('(cached_author_year = ? OR cached_author_year = ?)', author_year, author_year.gsub(' & ', ' and '))
          t.count > 0 ? t : scope
        end

        # @return [Hash]
        #   we inspect this internally, so it has to be decoupled
        def protonym_result
          return @protonym_result if @protonym_result
          h = {}
          RANK_MAP.each_key do |r|
            h[r] = protonyms(r).to_a
          end
          @protonym_result = h
          @protonym_result
        end

        # @return [Hash]
        def parse_values
          h = {
            author: author,
            year: year
          }
          RANK_MAP.each_key do |r|
            h[r] = send(r)
          end
          h
        end

        # @return [Hash]
        #   summary for rendering purposes
        def result
          @result ||= build_result
        end

        # @return [Hash]
        def build_result
          @result = {}
          @result[:protonyms] = protonym_result
          @result[:parse] = parse_values
          @result[:unambiguous] = is_unambiguous?
          @result[:existing_combination_id] = combination_exists?.try(:id)
          @result[:other_matches] = other_matches
          @result
        end

        # @return [Combination]
        #   ranks that are unambiguous have their Protonym set
        def combination
          @combination ||= set_combination
        end

        def set_combination
          c = Combination.new
          RANK_MAP.each_key do |r|
            c.send("#{r}=", unambiguous_at?(r))
          end
          c
        end

        # @return [Combination, false]
        #    the Combination, if it exists
        def combination_exists?
          if is_unambiguous?
            Combination.match_exists?(**combination.protonym_ids_params) # TODO: pass name?
          else
            false
          end
        end

        def author_word_position 
          if a = parse_result[:words]
            b = (a.detect { |v| v[:wordType] == 'AUTHOR_WORD'})&.dig(:start)
            p = [name.length, b].compact.min
          end
        end

        def name_without_author_year
          pos = author_word_position
          # author_word doesn't point to parens if any
          offset = pos > 0 && '(' == name[pos-1] ? 2 : 1

          name[0..pos - offset].strip
        end

        # @return [Hash]
        #   `:verbatim` - names that have verbatim supplied, these should be the only names NOT parsed that user is interested in
        #   `:subgenus` - names that exactly match a subgenus, these are potential new combinations as Genus alone 
        #   `:original_combination` - names that exactly match the original combination
        def other_matches
          h = { 
            verbatim: [],
            subgenus: [], 
            original: []
          }

          h[:verbatim] = TaxonName.where(project_id: project_id, cached: name_without_author_year).
            where('verbatim_name is not null').order(:cached).all.to_a if parseable
          
          h[:subgenus] = Protonym.where(
            project_id: project_id, 
            name: genus, 
            rank_class: Ranks.lookup(nomenclature_code, :subgenus)
          ).all.to_a

          h[:original_combination] = Protonym.where(project_id: project_id). 
            where( cached_original_combination: name_without_author_year
                 ).all.to_a if parseable

          h
        end

      end
    end
  end
end

