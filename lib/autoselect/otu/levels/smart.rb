# lib/autoselect/otu/levels/smart.rb
module Autoselect
  module Otu
    module Levels
      # Delegates to the existing OTU autocomplete query.
      # When the !n operator is present, returns a new-OTU form sentinel instead of database results.
      class Smart < ::Autoselect::Levels::Smart

        def query_class
          ::Queries::Otu::Autocomplete
        end

        # @return [Array<Otu or OpenStruct>]
        def call(term:, operator: nil, project_id: nil, user_id: nil, **kwargs)
          if operator == :new_record
            name_prefill = term.presence || ''
            [
              OpenStruct.new(
                id: nil,
                name: "Create new OTU: #{name_prefill}".strip,
                taxon_name: nil,
                _otu_new_form: { mode: 'new_otu_form', name_prefill: }
              )
            ]
          else
            super
          end
        end

      end
    end
  end
end
