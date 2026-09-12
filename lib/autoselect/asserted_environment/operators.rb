# lib/autoselect/asserted_environment/operators.rb
module Autoselect
  module AssertedEnvironment
    # AssertedEnvironment has no Smart level to back the record-list operators
    # (!u/!r/!b/!!), and no new-record modal to back !n - drop them so the
    # client doesn't advertise operators that would silently do nothing.
    module Operators
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def operator_map
          ::Autoselect::Operators::OPERATORS.except(
            :recent_mine, :recent, :pinboard, :pinboard_top, :new_record
          )
        end
      end
    end
  end
end
