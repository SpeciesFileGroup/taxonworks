# lib/autoselect/asserted_environment/autoselect.rb
module Autoselect
  module AssertedEnvironment
    class Autoselect < ::Autoselect::Base
      include ::Autoselect::AssertedEnvironment::Operators

      def resource_path
        '/asserted_environments/autoselect'
      end

      # Ordered level stack — defines the fuse escalation sequence.
      def levels
        [
          ::Autoselect::AssertedEnvironment::Levels::Fast.new,
          ::Autoselect::AssertedEnvironment::Levels::Envo.new,
        ]
      end

      # AssertedEnvironment records are per-object (polymorphic) join rows, so,
      # unlike other models, selecting a result never references its `id` -
      # both a Fast-level hit (an existing AssertedEnvironment) and an
      # Envo-level hit (a pseudo-record, id: nil) carry the same uri/uri_label
      # shape here. The client uses these to create a new AssertedEnvironment
      # for whatever object it is annotating.
      # @param record [::AssertedEnvironment or OpenStruct]
      # @return [Hash]
      def response_values(record)
        { uri: record.uri, uri_label: record.uri_label }
      end

    end
  end
end
