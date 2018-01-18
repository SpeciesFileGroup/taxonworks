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

        # the query string
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

        # String, the post ' in ' bit
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

        # @return [Hash, nil]
        def authorship
          if d = detail[:species]
            d[:basionymAuthorTeam]
          end
        end

        # @return [String, nil]
        def author
          if a = authorship
            Utilities::Strings.authorship_sentence(a[:author])
          end
        end

        # @return [String, nil]
        def year
          if a = authorship
            return a[:year]
          end
          nil
        end

        # @return [Boolean]
        def is_unambiguous?
          RANK_MAP.keys.each do |r|
            return false if send(r) && !unambiguous_at?(r)
          end
          true
        end 

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


        def sources
          Source.where( )
        end

        # @return [Scope]
        #    Protonyms at a given rank
        def ranked_protonyms(rank)
          basic_scope(rank).where(rank_class: Ranks.lookup(nomenclature_code, rank))
        end

        # @return [Scope]
        #   Protonyms grouped by nomenclatural group, for a rank
        def grouped_protonyms(rank)
          case rank
          when :genus, :subgenus
            basic_scope(rank).is_genus_group
          when :species, :subspecies
            basic_scope(rank).is_species_group
          else
            Protonym.none
          end
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
