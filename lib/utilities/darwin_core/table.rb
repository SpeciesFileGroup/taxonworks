# A wrapper for DarwinCore Occurrence data as native Ruby objects.
# Accepts input as CSV, TSV string, or File.
# Outputs as CSV, TSV string, or File.
#
# @author Claude (>50% of code)
#
class Utilities::DarwinCore::Table

  # @return [Array<String>]
  #   column headers
  attr_reader :headers

  # @return [Array<Hash>]
  #   each row is a Hash keyed by header string
  attr_reader :rows

  # @return [Array<Hash>]
  #   error/warning log entries from compaction or validation
  #   each entry: { type: :error|:warning, column:, message:, values: }
  attr_accessor :errors

  # Construct a Table from one of three input types:
  #
  # @param csv [CSV, nil] a parsed CSV object with headers
  # @param tsv_string [String, nil] a TSV-formatted string (tab-delimited, first row is headers)
  # @param file [String, nil] path to a TSV file
  def initialize(csv: nil, tsv_string: nil, file: nil)
    @errors = []
    @headers = []
    @rows = []

    sources = [csv, tsv_string, file].compact
    raise ArgumentError, 'Provide exactly one of csv:, tsv_string:, or file:' unless sources.size == 1

    if csv
      load_from_csv(csv)
    elsif tsv_string
      load_from_tsv_string(tsv_string)
    elsif file
      load_from_file(file)
    end
  end

  # @return [CSV]
  #   a CSV object with headers
  def to_csv
    output = ::CSV.generate(col_sep: "\t", headers: headers, write_headers: true) do |csv_out|
      rows.each do |row|
        csv_out << headers.map { |h| row[h] }
      end
    end

    ::CSV.parse(output, col_sep: "\t", headers: true)
  end

  # @return [String]
  #   TSV-formatted string
  def to_tsv
    lines = [headers.join("\t")]
    rows.each do |row|
      lines << headers.map { |h| row[h] }.join("\t")
    end
    lines.join("\n") + "\n"
  end

  # Write TSV data to a file.
  #
  # @param path [String] output file path
  # @return [String] the path written to
  def to_file(path)
    File.write(path, to_tsv)
    path
  end

  # Compact rows by merging on a key column.
  #
  # @param by [Symbol] the compaction strategy (:catalog_number)
  # @param preview [Boolean] if true, validate only — do not modify data
  # @return [Utilities::DarwinCore::Table] self (mutated unless preview)
  def compact(by: :catalog_number, preview: false)
    case by
    when :catalog_number
      Utilities::DarwinCore::Compact.by_catalog_number(self, preview:)
    else
      raise ArgumentError, "Unknown compact strategy: #{by}"
    end
    self
  end

  private

  def load_from_csv(csv)
    @headers = csv.headers.map(&:to_s)
    csv.each do |row|
      @rows << headers.each_with_object({}) { |h, hash| hash[h] = row[h] }
    end
  end

  def load_from_tsv_string(tsv_string)
    csv = ::CSV.parse(tsv_string, col_sep: "\t", headers: true)
    load_from_csv(csv)
  end

  def load_from_file(path)
    raise ArgumentError, "File not found: #{path}" unless File.exist?(path)
    load_from_tsv_string(File.read(path))
  end
end
