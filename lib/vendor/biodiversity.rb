
module TaxonWorks
  module Vendor
    module Biodiversity
      class Result
        attr_accessor :query_string

        attr_accessor :project_id

        attr_accessor :parse_result

        def initialize(query_string: nil, project_id: nil)
          @project_id = project_id
          @query_string = query_string
        end

        def parse_result
          @parse_result ||= ScientificNameParser.new.parse(query_string)
        end

        def protonyms(name, rank)
          Protonym.where(project_id: project_id, name: name, rank_string: Ranks.lookup)
        end

        def string(rank)
        end

        def genera
        end

        def subgenera
        end

        def species
        end

        def subspecies
        end

        def to_json

        end

      end

    end
  end
end
