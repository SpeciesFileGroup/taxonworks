module BatchLoad
  class Import::Otus::CastorInterpreter < BatchLoad::Import

    def initialize(**args)
      super(args)
    end

    def build_otus
      @total_data_lines = 0
      i = 0

      # loop throw rows
      csv.each do |row|
        i += 1

        parse_result = BatchLoad::RowParse.new
        parse_result.objects[:otu] = []

        @processed_rows[i] = parse_result

        begin # processing
          otu_identifier_castor_text = row["guid"]
          otu_identifier_castor = {
            type: "Identifier::Global::Uri",
            identifier: otu_identifier_castor_text
          }

          otu_identifiers = []
          otu_identifiers.push(otu_identifier_castor) if otu_identifier_castor.present?

          taxon_name = TaxonName.with_identifier(row["guid"]).take

          otu_attributes = {
            name: row["name"]
          }

          otu = Otu.new(otu_attributes)
          otu.taxon_name = taxon_name if taxon_name.present?
          parse_result.objects[:otu].push otu

          @total_data_lines += 1 if otu.present?
        rescue
            # ....
        end
      end

      @total_lines = i
    end

    def build
      if valid?
        build_otus
        @processed = true
      end
    end
  end
end
