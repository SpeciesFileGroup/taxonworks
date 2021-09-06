class ImportDataset::DarwinCore < ImportDataset
  # self.abstract_class = true # TODO: Why causes app/views/shared/data/project/_show.html.erb to fail when visiting /import_datasets/list if uncommented?

  after_create -> (dwc) { ImportDatasetStageJob.perform_later(dwc) }

  before_destroy :destroy_namespace

  CHECKLIST_ROW_TYPE = "http://rs.tdwg.org/dwc/terms/Taxon"
  OCCURRENCES_ROW_TYPE = "http://rs.tdwg.org/dwc/terms/Occurrence"

  def initialize(params)
    import_settings = params.delete(:import_settings)
    super(params)

    self.metadata = {
      core_headers: [],
      namespaces: {
        core: nil,
        eventID: nil
      }
    }

    set_import_settings(import_settings || {})
  end

  def core_records_fields
    dataset_record_fields.with_record_class(core_records_class)
  end

  # @param [string] file_path
  #   Path to DwC-A file
  # @return [Checklist, Occurrences, Unknown]
  # Returns the appropriate ImportDataset::DarwinCore subclass instantiated (not saved) for the supplied params
  def self.create_with_subtype_detection(params)
    core_type = nil

    return Unknown.new unless params[:source]

    begin
      path = params[:source].tempfile.path
      if path =~ /\.zip\z/i
        dwc = ::DarwinCore.new(path)
        core_type = dwc.core.data[:attributes][:rowType]

        ### Check all files are readable
        [dwc.core, *dwc.extensions].each do |table|
          table.read { |data, errors| raise "Errors found when reading data" unless errors.empty? }
        end
      else
        if path =~ /\.(xlsx?|ods)\z/i
          headers = CSV.parse(Roo::Spreadsheet.open(path).to_csv, headers: true).headers
        else
          headers = CSV.read(path, headers: true, col_sep: "\t", quote_char: nil, encoding: 'bom|utf-8').headers
        end

        if headers.include? "occurrenceID"
          core_type = OCCURRENCES_ROW_TYPE
        elsif headers.include? "taxonID"
          core_type = CHECKLIST_ROW_TYPE
        end
      end
    rescue Errno::ENOENT, RuntimeError => e # TODO: dwc-archive gem should probably detect missing (or wrongly mapped) files and raise its own exception
      return Unknown.new(params.merge({error_message: "#{e.message}"}))
    end

    case core_type
    when OCCURRENCES_ROW_TYPE
      Occurrences.new(params)
    when CHECKLIST_ROW_TYPE
      Checklist.new(params)
    else
      Unknown.new(params.merge({error_message: "unknown DwC-A core type '#{core_type}'."}))
    end
  end

  # @return [String]
  # Sets up import dataset for import and returns UUID. If already started same UUID is returned (unless last activity was more than 10 minutes ago).
  # Do not call if there are changes that have not been persisted
  def start_import(&block)
    with_lock do
      case self.status
      when 'Ready'
        self.status = 'Importing'
        self.metadata['import_uuid'] = SecureRandom.uuid
      when 'Importing'
        self.metadata['import_uuid'] = SecureRandom.uuid if self.updated_at < 10.minutes.ago
      else
        raise "Invalid initial state"
      end
      save!

      yield if block_given?
    end

    self.metadata['import_uuid']
  end

  # Sets import dataset to stop importing data. Do not call if there are changes that have not been persisted.
  def stop_import
    with_lock do
      if self.status == 'Importing'
        self.status = 'Ready'
        self.metadata.except!('import_uuid', 'import_start_id', 'import_filters', 'import_retry_errored')
        save!
      end
    end
  end

  # @return [Hash]
  # @param [Integer] max_time
  #   Maximum time to spend processing records.
  # @param [Integer] max_records
  #   Maximum number of records to be processed.
  # @param [Boolean] retry_errored
  #   Also looks up for errored records when importing (default is looking for records with Status=Ready)
  # @param [Hash] filters
  #   (Column-index, value) pairs of filters to apply when searching for records to import (default none)
  # @param [Integer] record_id
  #   Indicates the record to be imported (default none). When used filters are ignored.
  # Returns the updated dataset records. Do not call if there are changes that have not been persisted
  def import(max_time, max_records, retry_errored: nil, filters: nil, record_id: nil)
    imported = []

    lock_time = Time.now
    old_uuid = self.metadata['import_uuid']
    start_import do
      lock_time = Time.now - lock_time
      filters = self.metadata['import_filters'] if filters.nil?
      retry_errored = self.metadata['import_retry_errored'] if retry_errored.nil?
      start_id = self.metadata['import_start_id'] if retry_errored

      status = ["Ready"]
      status << "Errored" if retry_errored
      records = core_records.where(status: status).order(:id).limit(max_records) #.preload_fields
      filters&.each do |key, value|
        records = records.where(id: core_records_fields.at(key.to_i).with_value(value).select(:dataset_record_id))
      end
      records = records.where(id: start_id..) if start_id

      records = core_records.where(id: record_id) if record_id

      records = records.all
      start_time = Time.now - lock_time

      dwc_data_attributes = project.preferences["model_predicate_sets"].map do |model, predicate_ids|
        [model, Hash[
          *Predicate.where(id: predicate_ids)
            .select { |p| /^http:\/\/rs.tdwg.org\/dwc\/terms\/.*/ =~ p.uri }
            .map {|p| [p.uri.split('/').last, p]}
            .flatten
          ]
        ]
      end.to_h

      records.each do |record|
        imported << record.import(dwc_data_attributes)

        break if 1000.0*(Time.now - start_time).abs > max_time
      end

      if imported.any? && record_id.nil?
        self.metadata.merge!({
          'import_start_id' => imported.last&.id + 1,
          'import_filters' => filters,
          'import_retry_errored' => retry_errored
        })
        save!

        new_uuid = self.metadata['import_uuid']
        ImportDatasetImportJob.perform_later(self, new_uuid, max_time, max_records) unless old_uuid == new_uuid
      else
        self.stop_import
      end
    end

    imported
  end

  # @return [Hash]
  # Returns a hash with the record counts grouped by status
  def progress
    core_records.group(:status).count
  end

  # Stages DwC-A records into DB.
  def stage
    if status == "Staging" # ActiveJob being retried could cause this state
      transaction do
        core_records_fields.delete_all
        dataset_records.delete_all
      end
    end

    update!(status: "Staging") if status == "Uploaded"

    if status != "Ready"
      perform_staging
      update!(status: "Ready")
    end
  end

  # Sets import settings for this dataset
  def set_import_settings(import_settings)
    metadata["import_settings"] ||= {}
    import_settings.each { |k, v| metadata["import_settings"].merge!({k => v}) }
    save!
    metadata["import_settings"]
  end

  def get_core_record_identifier_namespace
    id = metadata.dig("namespaces", "core")

    if id.nil? || (@core_record_identifier_namespace ||= Namespace.find_by(id: id)).nil?
      random = SecureRandom.hex(4)
      project_name = Project.find(Current.project_id).name

      namespace_name = "#{core_records_identifier_name} namespace for \"#{description}\" dataset in \"#{project_name}\" project [#{random}]"

      @core_record_identifier_namespace = Namespace.create!(
        name: namespace_name,
        short_name: "#{core_records_identifier_name}-#{random}",
        verbatim_short_name: core_records_identifier_name,
        delimiter: ':'
      )

      metadata["namespaces"]["core"] = @core_record_identifier_namespace.id
      save!
    end

    @core_record_identifier_namespace
  end

  protected

  def get_records(source)
    records = { core: [], extensions: {} }
    headers = { core: [], extensions: {} }

    if source.path =~ /\.zip\z/i
      dwc = ::DarwinCore.new(source.path)

      headers[:core] = get_dwc_headers(dwc.core)
      records[:core] = get_dwc_records(dwc.core)

      dwc.extensions.each do |extension|
        type = extension.properties[:rowType]
        records[:extensions][type] = get_dwc_records(extension)
        headers[:extensions][type] = get_dwc_headers(extension)
      end
    elsif source.path =~ /\.(txt|tsv|xlsx?|ods)\z/i
      if source.path =~ /\.(txt|tsv)\z/i
        records[:core] = CSV.read(source.path, headers: true, col_sep: "\t", quote_char: nil, encoding: 'bom|utf-8')
      else
        records[:core] = CSV.parse(Roo::Spreadsheet.open(source.path).to_csv, headers: true)
      end
      records[:core] = records[:core].map { |r| r.to_h }
      headers[:core] = records[:core].first.to_h.keys
    else
      raise "Unsupported input format"
    end

    return records, headers
  end

  def get_dwc_headers(table)
    headers = []

    headers[table.id[:index]] = "id" if table.id
    table.fields.each { |f| headers[f[:index]] = get_normalized_dwc_term(f) if f[:index] }

    table.read_header.first.each_with_index { |f, i| headers[i] ||= f.strip }

    get_dwc_default_values(table).each.with_index(headers.length) { |f, i| headers[i] = get_normalized_dwc_term(f) }

    headers
  end

  def get_dwc_records(table)
    records = []
    headers = get_dwc_headers(table)

    records = table.read.first.map do |row|
      record = {}
      row.each_with_index { |v, i| record[headers[i]] = v }
      defaults = get_dwc_default_values(table)
      defaults.each.with_index(headers.length - defaults.length) { |f, i| record[headers[i]] = f[:default] }
      record
    end

    return records
  end

  def default_nomenclatural_code
    self.metadata.dig("import_settings", "nomenclatural_code")&.downcase&.to_sym || :iczn
  end

  private

  def get_dwc_default_values(table)
    table.fields.select { |f| f.has_key? :default }
  end

  def get_normalized_dwc_term(field)
    # TODO: Think what to do about complex namespaces like "/std/Iptc4xmpExt/2008-02-29/" (currently returning the full URI as header)
    term = field[:term].match(/\/([^\/]+)\/terms\/.*(?<=\/)([^\/]+)\/?$/)
    #headers[field[:index]] = term ? term[1..2].join(":") : field[:term]
    term ? term[2] : field[:term]
  end

  def destroy_namespace
    Namespace.find_by(id: metadata["identifier_namespace"])&.destroy # If in use or gone no deletion happens
  end

end
