module Vendor
  module Gnfinder 

    class Result
      attr_accessor :names, :unique_names

      attr_accessor :project_id

      attr_accessor :ocr_failure

      def initialize(json, project_id = nil)
        if json.kind_of?(Hash) && !(json.dig(:metadata, :total_words) == 1)
          build_names(json, project_id) 
        else
          @ocr_failure = true 
        end
      end

      def build_names(json, project_id)
        @names = json[:names]&.map{|n| Vendor::Gnfinder::Name.new(n, project_id)}
          &.sort{|a,b| a.name <=> b.name} || []
      end

      # @return [Hash]
      def unique_names
        if !@unique_names
          r = {}
          names.each do |n|
            if r[n.name] 
              r[n.name].push n
            else
              r[n.name] = [n]
            end
          end
          @unique_names = r
        end
        @unique_names
      end

      def found_names
        unique_names.select{|k, v| v.first.is_in_taxonworks? } 
      end

      def missing_names
        unique_names.select{|k, v| !v.first.is_in_taxonworks? } 
      end

      def found_all?
        missing_names.empty?
      end

    end
  end
end
