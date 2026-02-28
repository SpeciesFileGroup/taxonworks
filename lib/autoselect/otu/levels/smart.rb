# lib/autoselect/otu/levels/smart.rb
module Autoselect
  module Otu
    module Levels
      # Delegates to the existing OTU autocomplete query.
      # The !n (new_record) operator is handled client-side; this level never receives it.
      class Smart < ::Autoselect::Levels::Smart

        def query_class
          ::Queries::Otu::Autocomplete
        end

      end
    end
  end
end
