module TaxonWorks
  module Vendor
    module Gnfinder
      class Result

        attr_accessor :project_id
        attr_accessor :client

        attr_accessor :names, :unique_names, :new_names

        def initialize(_client, _project_id = [])
          @project_id = _project_id
          @client = _client
          @names = build_names
        end

        def score
          t = unique_names.keys.count.to_f
          sum_odds = unique_names.values.inject(0){|sum, names| sum += names.first.log_odds}
          sum_odds / t
        end

        def probable_source_of_text
          case score
          when 3..23
            if client.language == 'eng'
              'original text'
            else
              'uncertain (language)'
            end
          else
            if client.language == 'eng'
              'secondary OCR'
            else
              'uncertain (language)'
            end
          end
        end

        def ocr_failure
          client.names.length == 0
        end

        # @return [Hash]
        def unique_names
          if !@unique_names
            r = {}
            names.each do |n|
              if r[n.found.name]
                r[n.found.name].push n
              else
                r[n.found.name] = [n]
              end
            end
            @unique_names = r
          end
          @unique_names
        end

        # @return [Hash]
        def new_names
          unique_names.select{|k,v| v.first.is_new_name?  }
        end

        def found_names
          unique_names.select{|k, v| v.first.is_in_taxonworks? }
        end

        def missing_names
          unique_names.select{|k, v| !v.first.is_in_taxonworks? }
        end

        def missing_new_names
          missing_names.select{|k, v| v.first.is_new_name? && !v.first.is_low_probability? }
        end

        def missing_other_names
          missing_names.select{|k, v| !v.first.is_new_name? && !v.first.is_low_probability? }
        end

        def missing_low_probability_names
          missing_names.select{|k, v| v.first.is_low_probability? }
        end

        def found_all?
          missing_names.empty?
        end

        def verified_names
          unique_names.select{|k, v| v.first.is_verified? }
        end

        private

        def build_names
          n = client.names.map{|n|
            Vendor::Gnfinder::Name.new(n, project_id)
          }.sort{|a,b| a.found.name <=> b.found.name}
          n ||= []
          @names = n
        end

      end
    end
  end
end