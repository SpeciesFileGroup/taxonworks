# lib/autoselect/asserted_environment/operators.rb
module Autoselect
  module AssertedEnvironment
    # AssertedEnvironment has no new-record modal to back !n - drop it, since
    # creating one is complicated by requiring an object selection (there is
    # no standalone form; see app/views/asserted_environments/new.html.erb).
    #
    # The record-list operators (!u/!r/!b/!!) are backed fine: Levels::Smart
    # delegates to Queries::AssertedEnvironment::Filter, and
    # Queries::Concerns::Users (which supplies updated_since/user_id scoping)
    # is included unconditionally by the Query::Filter base class - every
    # Filter subclass gets it for free, no per-model include needed.
    module Operators
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def operator_map
          ::Autoselect::Operators::OPERATORS.except(:new_record)
        end
      end
    end
  end
end
