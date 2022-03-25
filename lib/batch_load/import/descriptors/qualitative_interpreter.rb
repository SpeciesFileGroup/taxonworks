module BatchLoad
  class Import::Descriptors::QualitativeInterpreter < BatchLoad::Import

    # needed?
    attr_accessor :descriptors
    attr_accessor :character_states

    # @param [Hash] args
    def initialize(**args)
      @descriptors = {}
      @character_states = {}
      super(**args)
    end

    # @return [csv, nil]
    def csv
      begin
        @csv ||= CSV.parse(
          @file.tempfile.read.force_encoding('utf-8'), # force encoding is likely a very bad idea, but instructinos say "utf-8"
          headers: false,
          col_sep: "\t",
          encoding: 'utf-8',
          skip_blanks: true)

      rescue encoding::undefinedconversionerror => e

      rescue argumenterror => e
        @processed = false
        @file_errors.push("error converting file. #{e}")
        return nil
      rescue csv::malformedcsverror => e
        @processed = false
        @file_errors.push("error converting file. #{e}")
        return nil
      end
    end

    # @return [Integer]
    def build_descriptors
      i = 0 
      csv.each do |row|
        parse_result = BatchLoad::RowParse.new

        parse_result.objects[:descriptor] = []
        parse_result.objects[:character_states] = []

        descriptor = nil
        descriptor_attributes = {
          name: row.shift,
          project_id: project_id,
          by: user_id
        }

        # THere are no validatinos on duplicate Descriptor::Qualitative yet
        # descriptor_match = Digest::SHA256.digest(descriptor_attributes.to_s)
        # descriptor = Descriptor::Qualitative.new(descriptor_attributes) # if descriptor.blank?

        parse_result.objects[:descriptor].push(descriptor)

        # build character states
        row.each_with_index do |n, i|
          break if n.blank?
          parse_result.objects[:character_states].push CharacterState.new(
            descriptor: descriptor,
            name: n,
            label: i,
            project_id: project_id,
            by: user_id
          )
        end

        # attach the results to the row
        @processed_rows[i] = parse_result

        i += 1
      end


      @total_lines = i - 1
    end

    def build
      if valid?
        build_descriptors
        @processed = true
      end
    end

  end
end
