module BatchFileLoad
  class Import

    attr_accessor :errors
    attr_accessor :processed_files
    attr_accessor :files

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

      @total_records_created = 0

      build
    end

    def create
      get_all_objects.each do |object|
        object.save
      end
    end

    def total_records_created
      raise 'This method must be provided in the respective subclass.'
    end

    def valid?
      @project_id && @user && @filenames && @file_contents
    end

    protected

    def build
      raise 'This method must be provided in the respective subclass.'
    end

    private

    def ready_to_create?
      valid? && @processed && import_level_ok?
    end

    def import_level_ok?
      @processed_files[:objects]
    end

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