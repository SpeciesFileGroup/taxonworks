# lib/autoselect/asserted_environment/levels/smart.rb
module Autoselect
  module AssertedEnvironment
    module Levels
      class Smart < ::Autoselect::Levels::Smart

        def query_class
          ::Queries::AssertedEnvironment::Autocomplete
        end

      end
    end
  end
end
