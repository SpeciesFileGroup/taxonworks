module BatchLoad
  class Import::TypeMaterials::SimpleInterpreter < BatchLoad::Import

    # @param [Hash] args
    def initialize(**args)
      super(args)
    end

    # @return [Integer]
    def build_type_materials
      @total_data_lines = 0
      i = 0

      csv.each do |row|
        i += 1

        parse_result = BatchLoad::RowParse.new
        parse_result.objects[:type_materials] = []

        @processed_rows[i] = parse_result

        begin
          collection_identifier = Identifier.find_by_cached(row['collection_object_identifier'])
          protonym = TaxonName.find_by_cached(row['protonym'])
          type_type = row['type_type'].downcase

          # next if (collection_identifier.nil? or protonym.nil?)

          type_material = TypeMaterial.new({
                                             protonym: protonym,
                                             collection_object: collection_identifier&.identifier_object,
                                             type_type: type_type,
                                           })
          parse_result.objects[:type_materials].push type_material
          @total_data_lines += 1 if type_material.present?
          # rescue TODO: THIS IS A GENERATED STUB, it does not function
        end
      end
      @total_lines = i
    end

    # @return [Boolean]
    def build
      if valid?
        build_type_materials
        @processed = true
      end
    end
  end
end
