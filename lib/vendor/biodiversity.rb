module TaxonWorks
  module Vendor

    # Wraps the biodiversity gem (https://github.com/GlobalNamesArchitecture/biodiversity)
    # Links parsed string results to Protonyms/Combinations in TaxonWorks 
    module Biodiversity

      RANK_MAP = {
        genus: :genus,
        subgenus: :infragenus,
        species: :species,
        subspecies: :infraspecies
      }

      class Result

        # query string
        attr_accessor :name

        # how to match
        attr_accessor :mode

        # project to query against
        attr_accessor :project_id

        # one of :iczn, :icn, :icnb
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

        # String, the bit after ' in '
        attr_reader :citation

        # query_string: 
        #
        # mode:
        #   ranked: return names at that queried rank only (e.g. only match a subgenus to rank subgenus
        #   groups: return names at Group level (species or genus), i.e. a subgenus name in query will match genus OR subgenus in database
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
          n, @citation = preparse
          @parse_result ||= ScientificNameParser.new.parse(n)
        end

        def preparse
          name.split(' in ') 
        end

        # @return [Hash]
        def detail 
          if a = parse_result[:scientificName]
            if a[:details]
              return a[:details].first
            end
          end
          {}
        end

        # @return [String, false]
        def genus
          detail[:genus] && detail[:genus][:string]
        end

        # @return [String, false]
        def subgenus
          detail[:infragenus] && detail[:infragenus][:string]
        end

        # @return [String, false]
        def species
          detail[:species] && detail[:species][:string]
        end

        # @return [String, false]
        def subspecies
          if m = detail[:infraspecies]
            m.each do |n|
              return n[:string] if n[:rank] == 'n/a'
            end 
          end  
        end

        # @return [String, false]
        def variety
          if m = detail[:infraspecies]
            m.each do |n|
              return n[:string] if n[:rank] == 'var.'
            end 
          end  
        end

        def finest_rank
          RANK_MAP.keys.reverse.each do |k|
            return k if send(k)
          end
        end

        # @return [Hash, nil]
        def authorship
          if d = detail[finest_rank]
            d[:basionymAuthorTeam]
          end
        end

        # @return [String, nil]
        def author
          if a = authorship
            Utilities::Strings.authorship_sentence(a[:author])
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
            return a[:year]
          end
          nil
        end

        # @return [Boolean]
        #   true if there for each parsed piece of there name there is 1 and only 1 result
        def is_unambiguous?
          RANK_MAP.keys.each do |r|
            if !send(r).nil?
              return false unless unambiguous_at?(r)
            end
          end
          true
        end

        # @return [Boolean]
        def is_authored?
          author_year.size > 0
        end

        # @return [Boolean] 
        #   true if there is a single matching result
        def unambiguous_at?(rank)
          protonym_result[rank].size == 1
        end

        # @return [ String, false ]
        def string(rank = nil)
          self.send(rank)
        end

        # TODO: var., form

        # @return [Scope]
        def basic_scope(rank)
          Protonym.where(
            project_id: project_id, 
            name: string(rank)
          )
        end

        # @return [Scope]
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
        #   Protonyms grouped by nomenclatural group, for a rank
        def grouped_protonyms(rank)
          s = case rank
          when :genus, :subgenus
             basic_scope(rank).is_genus_group
          when :species, :subspecies
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
          h = {}
          RANK_MAP.keys.each do |r|
            h[r] = protonyms(r).to_a
          end
          h
        end

        # @return [Hash]
        def parse_values
          h = {}
          RANK_MAP.keys.each do |r|
            h[r] = send(r)
          end
          h[:author] = author
          h[:year] = year
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
          @result
        end

        # @return [Combination]
        #   ranks that are unambigous have their protonyms set
        def combination
          c = Combination.new
          RANK_MAP.keys.each do |r|
            c.send("#{r}_id=", protonym_result[r].first.try(:id)) if unambiguous_at?(r) 
          end
          c
        end

      end
    end
  end
end

