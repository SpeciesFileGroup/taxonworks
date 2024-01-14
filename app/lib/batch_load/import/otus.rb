require 'digest/bubblebabble'

module BatchLoad
  # TODO: Originally transliterated from Import::CollectionObjects: Remove this to-do after successful operation.
  class Import::Otus < BatchLoad::Import

    SAVE_ORDER = [:otu]

    attr_accessor :otus

    # @param [Hash] args
    def initialize(**args)
      @otus = {}
      super(**args)
    end

    # @return [Integer]
    def build_otus
      # test_build
      build_objects = {}
      i = 1 # accounting for headers
      csv.each do |row|
        parse_result = BatchLoad::RowParse.new

        # creation of the possible-objects list
        parse_result.objects[:otu] = []
        # attach the results to the row
        @processed_rows[i] = parse_result

        temp_row = row
        temp_row['project_id'] = @project_id.to_s if row['project_id'].blank?

        begin # processing the Otu !! TODO: if there is no rescue there is no point?
          otu = nil
          otu_attributes = {name: row['otu_name']}
          unless otu_attributes[:name].blank?
            otu_list = BatchLoad::ColumnResolver.otu(temp_row)
            otu = otu_list.item if otu_list.resolvable?
            otu_match = Digest::SHA256.digest(otu_attributes.to_s)
            otu = build_objects[otu_match] if otu.blank?
            otu = Otu.new(otu_attributes) if otu.blank?
            build_objects[otu_match] = otu
            parse_result.objects[:otu].push(otu)
          end
        end

        i += 1
      end
      @total_lines = i - 1
    end

    # @return [Boolean]
    def build
      if valid?
        build_otus
        @processed = true
      end
    end
  end
end

