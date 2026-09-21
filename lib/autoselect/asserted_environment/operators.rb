# lib/autoselect/asserted_environment/operators.rb
module Autoselect
  module AssertedEnvironment
    # AssertedEnvironment has no new-record modal to back !n - drop it, since
    # creating one is complicated by requiring an object selection (there is
    # no standalone form; see app/views/asserted_environments/new.html.erb).
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
