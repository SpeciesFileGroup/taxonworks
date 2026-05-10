# lib/autoselect/otu/levels/smart.rb
module Autoselect
  module Otu
    module Levels
      # Delegates to the existing OTU autocomplete query.
      # Handles the :new_record operator by returning a sentinel that triggers
      # OtuNewModal on the client side.
      class Smart < ::Autoselect::Levels::Smart

        def query_class
          ::Queries::Otu::Autocomplete
        end

        def call(term:, operator: nil, project_id: nil, user_id: nil, **kwargs)
          return new_otu_sentinel(term) if operator == :new_record
          super
        end

        private

        def new_otu_sentinel(name_prefill)
          [OpenStruct.new(
            id: nil,
            name: name_prefill,
            taxon_name: nil,
            _otu_new_form: { mode: 'new_otu_form', name_prefill: }
          )]
        end

      end
    end
  end
end
