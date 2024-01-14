module BatchFileLoad
  class Import::Otus::SimpleInterpreter < BatchFileLoad::Import
    # @param [Array] args
    def initialize(**args)
      super(**args)
    end

    # @return [Array]
    def build
      return if !valid?
      @processed = true

      @filenames.each_with_index do |name, file_index|
        objects_in_file = {}
        objects_in_file[:otu] = []

        file_content = @file_contents[file_index]
        otu = Otu.new({ name: file_content})
        ap file_content
        objects_in_file[:otu].push(otu)

        @processed_files[:names].push(name)
        @processed_files[:objects].push(objects_in_file)
      end
    end
  end
end
