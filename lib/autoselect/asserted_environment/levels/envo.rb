# lib/autoselect/asserted_environment/levels/envo.rb
module Autoselect
  module AssertedEnvironment
    module Levels
      # External level: searches the Environment Ontology (ENVO) via
      # Vendor::Envo (identical mechanism to AnatomicalPart's use of Hookkaido,
      # but hardcoded to the envo ontology - see Vendor::Envo). Results are
      # pseudo-records (OpenStruct, id: nil) - see
      # Autoselect::AssertedEnvironment::Autoselect#response_values for how
      # selecting one is turned into a new AssertedEnvironment.
      class Envo < ::Autoselect::Level

        def key
          :envo
        end

        def label
          'ENVO'
        end

        def description
          'Search the Environment Ontology (ENVO) for matching terms'
        end

        def external?
          true
        end

        # @param term [String]
        # @return [Array<OpenStruct>] pseudo-records with uri/uri_label set from
        #   the ENVO search result
        def call(term:, operator: nil, project_id: nil, user_id: nil, **_kwargs)
          return [] if term.blank?

          ::Vendor::Envo.search(term)[:results].map do |r|
            OpenStruct.new(id: nil, uri: r[:iri], uri_label: r[:label], description: r[:description])
          end
        end

        # Pseudo-records, so render directly rather than via the label_for_/
        # _autoselect_tag helper delegation (see Autoselect::Level docs).
        def record_label(record)
          record.uri_label.to_s
        end

        def record_label_html(record, term = nil)
          record.description.present? ? "#{record.uri_label}: #{record.description}" : record.uri_label.to_s
        end

        def record_info(record)
          [::Vendor::Envo.local_id(record.uri)]
        end

      end
    end
  end
end
