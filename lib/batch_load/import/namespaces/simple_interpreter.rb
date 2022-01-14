module BatchLoad
  class Import::Namespaces::SimpleInterpreter < BatchLoad::Import

    # @param [Hash] args
    def initialize(**args)
      super(**args)
    end

    # @return [Integer]
    def build_namespaces
      @total_data_lines = 0
      i = 0

      namespaces = {};

      # loop through rows
      csv.each do |row|
        i += 1

        parse_result = BatchLoad::RowParse.new
        parse_result.objects[:namespaces] = []

        @processed_rows[i] = parse_result

        begin
          namespace_attributes = {
            institution: row['institution'],
            name: row['name'],
            short_name: row['short_name'],
            verbatim_short_name: row['verbatim_short_name']
          };

          namespace = Namespace.new(namespace_attributes)
          parse_result.objects[:namespaces].push namespace
          @total_data_lines += 1 if namespace.present?
        # rescue TODO: THIS IS A GENERATED STUB, it does not function
        end
      end

      @total_lines = i
    end

    # @return [Boolean]
    def build
      if valid?
        build_namespaces
        @processed = true
      end
    end

  end
end
