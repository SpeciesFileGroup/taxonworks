module TaxonWorks
  module Vendor


    # Wraps the biodiversity gem, links parsed string
    # results to Protonyms in taxonworks
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

        attr_accessor :project_id

        # one of :iczn, :icn, :icnb
        attr_accessor :nomenclature_code

        # a Hash of rank => [Protonyms] like { genus: [<#>, <#>] }
        attr_accessor :parse_result

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

        def parse
          @parse_result ||= ScientificNameParser.new.parse(name)
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

        def genus
          detail[:genus] && detail[:genus][:string]
        end

        def subgenus
          detail[:infragenus] && detail[:infragenus][:string]
        end

        def species
          detail[:species] && detail[:species][:string]
        end

        def subspecies
          if m = detail[:infraspecies]
            m.each do |n|
              return n[:string] if n[:rank] == 'n/a'
            end 
          end  
        end

        def variety
          if m = detail[:infraspecies]
            m.each do |n|
              return n[:string] if n[:rank] == 'var.'
            end 
          end  
        end

        # @return [ String, false ]
        def string(rank = nil)
          self.send(rank)
        end

        # TODO: frm, form. etc.
        
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
        def ranked_protonyms(rank)
          basic_scope(rank).where(rank_class: Ranks.lookup(nomenclature_code, rank))
        end

        # @return [Scope]
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
        def result 
          [:genus, :subgenus, :species, :subspecies].inject({}){|hsh, r| hsh.merge!(r => protonyms(r).to_a) } 
        end

      end
    end
  end
end
