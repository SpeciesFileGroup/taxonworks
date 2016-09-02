module BatchFileLoad
  class Import

    attr_reader :processed_files
    attr_reader :processed
    attr_reader :errors
    attr_reader :file_errors
    attr_reader :filenames
    attr_reader :file_contents
    
    def initialize(project_id: nil, user_id: nil, files: nil, import_level: :warn)
      @project_id = project_id
      @user = User.find(user_id)
      @files = files
      @import_level = import_level

      @processed = false

      # WARNING: Beware of files with the same name, the content within them may be different
      # thus why filenames can NOT be used as keys for this reason
      # We also can't modify filenames by appending numbers at the end or whatever to
      # fix the previous issue in case the filename contains metadata for the file
      # in which this would break the metadata
      @processed_files = { names: [], objects: [] }

      @filenames = []
      @file_contents = []

      @files.each do |file|
        @filenames.push(file.original_filename)

        # WARNING: Once you call ".tempfile.read.force_encoding('utf-8')" on a tempfile as shown below,
        # the next time you call ".tempfile.read.force_encoding('utf-8')" on the same tempfile 
        # an empty string will be returned!
        @file_contents.push(file.tempfile.read.force_encoding('utf-8'))
      end

      @errors = []
      @file_errors = []

      @total_records_created = 0

      build
    end

    # Attempts to save each object from the files into the database
    def create
      if ready_to_create?
        @total_records_created = 0

        get_all_objects.each do |object|
          if object.save
            @total_records_created += 1
          end
        end
      else
        @errors << "Import level #{@import_level} has prevented creation." unless import_level_ok?
        @errors << "One of project_id, user_id or files has not been provided." unless valid?
      end
    end

    # Returns the number of objects that were successfully saved to the database
    def total_records_created
      @total_records_created
    end

    # Returns the total number of projects that got processed from each file
    def total_records_processed
      get_all_objects.length
    end

    # Returns the number of files that got processed
    def total_files_processed
      @processed_files[:names].length
    end

    # Checks if valid housekeeping and file attributes were supplied
    def valid?
      @project_id && @user && @filenames && @file_contents
    end

    # Anything can happen
    def warn_level_ok?
      true
    end

    # There must be records from each file
    def file_strict_level_ok?
      @filenames.each_with_index do |filename, index|
        return false if filename != @processed_files[:names][index] || @processed_files[:objects][index].empty?
      end
    end

    # Every record must be valid
    def object_strict_level_ok?
      get_all_objects.each do |object|
        return false if !object.valid?
      end
    end

    # There must be records from every file and every record must be valid
    def file_object_strict_level_ok?
      file_strict_level_ok? && object_strict_level_ok?
    end

    protected

    # Subclass implemented function that is responsible for interpreting the imported data from the files
    def build
      raise 'This method must be provided in the respective subclass.'
    end

    private

    # Returns true if ready to create all the objects and store in the database
    def ready_to_create?
      valid? && @processed && import_level_ok?
    end

    # Checks if a file passes the specificed import level
    def import_level_ok?
      case @import_level.to_sym
        when :warn
          warn_level_ok?
        when :file_strict 
          file_strict_level_ok?
        when :object_strict 
          object_strict_level_ok?
        when :file_object_strict 
          file_object_strict_level_ok?
        else
          false
      end
    end

    # Returns an array that has every object from each file
    def get_all_objects
      all_objects = []

      @processed_files[:objects].each do |hash|
        hash.each do |type, objects|
          objects.each do |object|
            all_objects.push(object)
          end
        end
      end
      
      all_objects
    end
  end
end