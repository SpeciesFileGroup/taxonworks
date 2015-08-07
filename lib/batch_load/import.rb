module BatchLoad
  class ParamError < StandardError; end;

  class FileError < StandardError; end;

  # A generic object for managing CSV based imports
  class Import

    # An index of all rows for which some data was present, 
    # index is line number, points to a RowParse instance
    attr_accessor :processed_rows

    # Cached calculation based on inspection of processed rows,
    # a successful row has at least one persisted object following
    # create
    attr_accessor :successful_rows

    # File is processable, at the basic level, and is  ready for preview/created
    attr_accessor :processed

    # An attempt was made to create new records 
    attr_accessor :create_attempted

    attr_accessor :project, :user

    # The number of non-header rows in the file
    attr_accessor :total_lines

    # The number of lines that have at least some data in some column
    attr_accessor :total_data_lines

    # How forgiving the import process is
    #  :warn -> all possible names will be added, with those not validating ignored
    #  :line_strict -> there is one record assumed / line, and each line must have a single valid record
    #  :strict -> all processed records must be valid
    attr_accessor :import_level

    # The input file, as it comes in on the form
    attr_accessor :file

    # The resultant csv table
    attr_accessor :csv

    # Errors with the file itself, rather than its content
    attr_accessor :file_errors

    # Errors from the import process itself.
    attr_accessor :errors

    def initialize(project_id: nil, user_id: nil, file: nil, process: true, import_level: :warn)
      @processed = false
      @import_level = import_level
      @project_id = project_id
      @user_id = user_id
      @file = file 

      @processed_rows = {}
      @successful_rows = nil

      @user = User.find(@user_id)

      @file_errors = [] 
      @errors = []

      @create_attempted = false 

      process && build
    end

    # The file to be processed
    # params[:file].tempfile coming from a multipart form
    def file=(value)
      @file = value
      csv
      @file 
    end

    def csv
      # begin
      @csv ||= CSV.parse(@file.tempfile, {headers: true, header_converters: :downcase, col_sep: "\t"})
      # rescue
      #   @processed = false
      #   @file_errors.push("Error reading file.  Is there a header row and at least one data row?  Are the columns tab delimited?")
      # end
      #  @csv  
    end

    def valid?
      return false unless @project_id && @user && @file && csv && errors.empty? && file_errors.empty?
      true
    end

    # return [Boolean] whether the instance is configured 
    def ready_to_create?
      valid? && processed? && import_level_ok?  
    end

    def import_level_ok?
      case import_level.to_sym
      when :warn
        warn_level_ok? 
      when :strict
        strict_level_ok?
      when :line_strict
        line_strict_level_ok?
      else
        false
      end
    end

    def warn_level_ok?
      true
    end

    def strict_level_ok?
      all_objects.each do |o|
        return false if !o.valid?
      end
      true
    end

    def line_strict_level_ok?
      total_data_lines == valid_objects.size
    end

    # Iterates in line order and attempts to save each record
    # return [true] 
    def create
       @create_attempted = true
      if ready_to_create? 
        # TODO: (additional!?) enumerate order per klass for save off
        sorted_processed_rows.each do |i, rp|
          rp.objects.each do |object_type, objs|
            objs.each do |o|
              o.save
            end
          end
        end
      else
        @errors << "Import level #{import_level} has prevented creation." if !import_level_ok?
        @errors << "CSV has not been processed." if !processed?
        @errors << "One of user_id, project_id or file has not been provided." if !valid?
      end
      true
    end

    def build
      raise 'This method must provided in each respective subclass.'
    end

    # return [Boolean] whether an attempt at creating records has occured 
    def create_attempted?
      create_attempted
    end

    # return [Boolean] whether an attempt to process the input file has occured
    def processed? 
      processed
    end

    # return [Integer] the total lines with data
    def total_data_lines
      @total_data_lines ||= processed_rows.keys.size
    end

    # return [Array] the line numbers that resulted in saved records
    def successful_rows 
      @successful_rows ||= processed_rows.keys.collect{|i| processed_rows[i].has_persisted_objects? ? i : nil}.sort.compact
    end

    # return [Integer] the total number of records created
    def total_records_created
      successful_rows.inject(t = 0){|t, i| t += processed_rows[i].persisted_objects.size }
    end

    # return [Hash] proccesed rows, sorted by line number
    #  ?! key order might not persist ?! 
    def sorted_processed_rows
      @processed_rows.sort.to_h
    end

    # return [Array] all objects (parsed records) that are .valid?
    def valid_objects
      all_objects.select{|o| o.valid?} 
    end

    # return [Array] all objects (parsed records)
    def all_objects
      processed_rows.collect{|i, rp| rp.all_objects}.flatten
    end

  end
end

