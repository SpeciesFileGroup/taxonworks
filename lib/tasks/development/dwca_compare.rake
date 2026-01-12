require 'shellwords'
require 'securerandom'
require 'fileutils'

namespace :tw do
  namespace :development do
    namespace :dwca do
      desc 'Compare two DwCA export directories or zip files for differences'
      task :compare, %i[path1 path2 show_all] => [:environment] do |_t, args|
        require 'csv'
        require 'digest'
        require 'zip'
        require 'tmpdir'

        if args[:path1].nil? || args[:path2].nil?
          puts 'Usage: rake tw:development:dwca:compare[path1,path2,show_all]'
          puts
          puts 'Compare DwCA exports from two directories or zip files.'
          puts 'Arguments can be directories with unzipped DwCA files or .zip files.'
          puts
          puts 'Arguments:'
          puts '  path1     - First DwCA directory or .zip file'
          puts '  path2     - Second DwCA directory or .zip file'
          puts '  show_all  - Optional: "all" to show all differences (default: first 15)'
          puts
          puts 'Examples:'
          puts '  rake tw:development:dwca:compare[/path/to/export1,/path/to/export2]'
          puts '  rake tw:development:dwca:compare[/path/to/export1.zip,/path/to/export2.zip]'
          puts '  rake tw:development:dwca:compare[/path/to/export1,/path/to/export2.zip,all]'
          exit 1
        end

        show_all = args[:show_all]&.downcase == 'all'
        comparer = DwcaComparer.new(args[:path1], args[:path2], show_all: show_all)
        begin
          comparer.compare
        ensure
          comparer.cleanup
        end
      end
    end
  end
end

# Comparison service object
class DwcaComparer
  def initialize(path1, path2, show_all: false)
    @path1 = File.expand_path(path1)
    @path2 = File.expand_path(path2)
    @show_all = show_all
    @differences = []
    @warnings = []
    @temp_dirs = []

    # Determine if paths are zip files or directories
    @dir1 = prepare_directory(@path1, 'dir1')
    @dir2 = prepare_directory(@path2, 'dir2')
  end

  def compare
    validate_directories

    puts '=' * 80
    puts 'Comparing DwCA Exports'
    puts '=' * 80
    puts "Directory 1: #{@dir1}"
    puts "Directory 2: #{@dir2}"
    puts '=' * 80
    puts

    files1 = Dir.glob(File.join(@dir1, '*')).map { |f| File.basename(f) }.sort
    files2 = Dir.glob(File.join(@dir2, '*')).map { |f| File.basename(f) }.sort

    compare_file_lists(files1, files2)

    common_files = files1 & files2
    common_files.each do |filename|
      compare_file(filename)
    end

    print_summary
  end

  def cleanup
    # Remove any temporary directories created for zip extraction
    @temp_dirs.each do |dir|
      FileUtils.rm_rf(dir) if Dir.exist?(dir)
    end
  end

  private

  # Color helpers
  def green(text) = "\e[32m#{text}\e[0m"
  def yellow(text) = "\e[33m#{text}\e[0m"
  def red(text) = "\e[31m#{text}\e[0m"

  def prepare_directory(path, label)
    unless File.exist?(path)
      abort("Error: Path does not exist: #{path}")
    end

    if File.directory?(path)
      path
    elsif File.file?(path) && path.end_with?('.zip')
      extract_zip(path, label)
    else
      abort("Error: Path must be a directory or .zip file: #{path}")
    end
  end

  def extract_zip(zip_path, label)
    temp_dir = Dir.mktmpdir("dwca_compare_#{label}_")
    @temp_dirs << temp_dir

    puts "Extracting #{File.basename(zip_path)} to temporary directory..."

    Zip::File.open(zip_path) do |zip_file|
      zip_file.each do |entry|
        next if entry.directory? # Skip directory entries

        dest_path = File.join(temp_dir, entry.name)
        FileUtils.mkdir_p(File.dirname(dest_path))

        # Extract manually by reading and writing
        File.open(dest_path, 'wb') do |f|
          f.write(entry.get_input_stream.read)
        end
      end
    end

    temp_dir
  end

  def validate_directories
    abort("Error: Directory does not exist: #{@dir1}") unless Dir.exist?(@dir1)
    abort("Error: Directory does not exist: #{@dir2}") unless Dir.exist?(@dir2)
  end

  def compare_file_lists(files1, files2)
    missing_in_dir2 = files1 - files2
    missing_in_dir1 = files2 - files1

    @differences << "Files in dir1 but not in dir2: #{missing_in_dir2.join(', ')}" if missing_in_dir2.any?
    @differences << "Files in dir2 but not in dir1: #{missing_in_dir1.join(', ')}" if missing_in_dir1.any?
  end

  def compare_file(filename)
    file1 = File.join(@dir1, filename)
    file2 = File.join(@dir2, filename)

    puts "Comparing: #{filename}"

    if filename.end_with?('.tsv')
      compare_tsv(file1, file2, filename)
    elsif filename.end_with?('.xml')
      compare_xml(file1, file2, filename)
    else
      compare_binary(file1, file2, filename)
    end

    puts
  end

  def compare_tsv(file1, file2, filename)
    # Quick hash check first
    if files_identical?(file1, file2)
      puts "  #{green('✓')} Files are identical"
      return
    end

    # Special case: data.tsv can be huge; decide:
    #   a) same
    #   b) same after row reordering (ERROR + note)
    #   c) not the same rows (ERROR)
    #   d) not the same rows, but UUID order is the same (ERROR)
    if filename == 'data.tsv'
      compare_data_tsv_rowset(file1, file2, filename)
      return
    end

    # More detailed comparison (OK for smaller files).
    csv1 = CSV.read(file1, col_sep: "\t", headers: true, encoding: 'UTF-8')
    csv2 = CSV.read(file2, col_sep: "\t", headers: true, encoding: 'UTF-8')

    # Compare headers
    if csv1.headers != csv2.headers
      missing_in_2 = csv1.headers - csv2.headers
      missing_in_1 = csv2.headers - csv1.headers

      removed_columns = ['UsageTerms', 'associatedObservationReference']
      is_removed_columns_case = (
        filename == 'media.tsv' &&
        (missing_in_2.sort == removed_columns.sort || missing_in_1.sort == removed_columns.sort)
      )

      if is_removed_columns_case
        source_csv = missing_in_2.any? ? csv1 : csv2
        removed_cols = missing_in_2.any? ? missing_in_2 : missing_in_1

        all_empty = removed_cols.all? do |col|
          source_csv.all? { |row| row[col].nil? || row[col].to_s.strip.empty? }
        end

        if all_empty
          @warnings << "#{filename}: Removed deprecated empty columns: #{removed_cols.join(', ')}"
          puts "  #{yellow('⚠')} Headers differ (removed deprecated empty columns: #{removed_cols.join(', ')})"
          puts "    Dir1 headers: #{csv1.headers.size} columns"
          puts "    Dir2 headers: #{csv2.headers.size} columns"
        else
          @differences << "#{filename}: Headers differ"
          puts "  #{red('✗')} Headers differ"
          puts "    Dir1 headers: #{csv1.headers.size} columns"
          puts "    Dir2 headers: #{csv2.headers.size} columns"
          puts "    Columns in dir1 but not dir2: #{missing_in_2.join(', ')}" if missing_in_2.any?
          puts "    Columns in dir2 but not dir1: #{missing_in_1.join(', ')}" if missing_in_1.any?
        end
      else
        @differences << "#{filename}: Headers differ"
        puts "  #{red('✗')} Headers differ"
        puts "    Dir1 headers: #{csv1.headers.size} columns"
        puts "    Dir2 headers: #{csv2.headers.size} columns"
        puts "    Columns in dir1 but not dir2: #{missing_in_2.join(', ')}" if missing_in_2.any?
        puts "    Columns in dir2 but not dir1: #{missing_in_1.join(', ')}" if missing_in_1.any?
      end
    else
      puts "  #{green('✓')} Headers match (#{csv1.headers.size} columns)"
    end

    # Compare row counts
    if csv1.size != csv2.size
      @differences << "#{filename}: Row count differs (#{csv1.size} vs #{csv2.size})"
      puts "  #{red('✗')} Row count differs: dir1=#{csv1.size}, dir2=#{csv2.size}"
    else
      puts "  #{green('✓')} Row count matches (#{csv1.size} rows)"
    end

    compare_tsv_content(csv1, csv2, filename)
  end

  def compare_tsv_content(csv1, csv2, filename)
    key_col = csv1.headers.find { |h| h =~ /^(id|coreid|occurrenceID)$/i } || csv1.headers.first
    return unless key_col

    sorted_comparison = false
    if filename == 'media.tsv'
      type_col = csv1.headers.find { |h| h == 'dc:type' }
      id_col = csv1.headers.find { |h| h == 'providerManagedID' }

      if type_col && id_col
        rows1 = csv1.sort_by { |row| [row[key_col].to_s, row[type_col].to_s, row[id_col].to_s] }
        rows2 = csv2.sort_by { |row| [row[key_col].to_s, row[type_col].to_s, row[id_col].to_s] }
        sorted_comparison = true
      else
        rows1 = csv1
        rows2 = csv2
      end
    else
      rows1 = csv1
      rows2 = csv2
    end

    max_rows = [rows1.size, rows2.size].max
    diff_count = 0
    nil_vs_empty_count = 0
    sample_diffs = []

    max_rows.times do |i|
      row1 = rows1[i]
      row2 = rows2[i]

      if row1.nil?
        diff_count += 1
        sample_diffs << "  Row only in dir2: #{key_col}=#{row2[key_col]}" if sample_diffs.size < 5
      elsif row2.nil?
        diff_count += 1
        sample_diffs << "  Row only in dir1: #{key_col}=#{row1[key_col]}" if sample_diffs.size < 5
      elsif row1.to_h != row2.to_h
        common_headers = row1.headers & row2.headers

        is_only_empty_diff = true
        common_headers.each do |header|
          v1 = row1[header]
          v2 = row2[header]
          next if v1 == v2
          unless (v1.nil? && v2 == '') || (v1 == '' && v2.nil?)
            is_only_empty_diff = false
            break
          end
        end

        if is_only_empty_diff
          nil_vs_empty_count += 1
          next
        end

        diff_count += 1
        if sample_diffs.size < 5
          sample_diffs << "  Row differs: #{key_col}=#{row1[key_col]}"
          common_headers.each do |header|
            v1 = row1[header]
            v2 = row2[header]
            next if v1 == v2
            next if (v1.nil? || v1 == '') && (v2.nil? || v2 == '')
            sample_diffs << "    #{header}: '#{v1}' vs '#{v2}'"
          end
        end
      end
    end

    if nil_vs_empty_count > 0
      @warnings << "#{filename}: #{nil_vs_empty_count} rows have nil vs empty string differences"
      puts "  #{yellow('⚠')} #{nil_vs_empty_count} row(s) have nil vs empty string differences (not counted as errors)"
    end

    if sorted_comparison && diff_count == 0
      unsorted_diff = false
      csv1.size.times do |i|
        if csv1[i].to_h != csv2[i].to_h
          unsorted_diff = true
          break
        end
      end

      if unsorted_diff
        @warnings << "#{filename}: Row order differs (content matches after sorting)"
        puts "  #{yellow('⚠')} Row order differs (content matches after sorting)"
      end
    end

    if diff_count > 0
      @differences << "#{filename}: #{diff_count} rows differ"
      puts "  #{red('✗')} Content differs: #{diff_count} row(s) differ"
      if sample_diffs.any?
        puts '  Sample differences (first 5):'
        sample_diffs.each { |diff| puts diff }
      end
      puts "  ... and #{diff_count - 5} more differences" if diff_count > 5
    else
      if filename == 'media.tsv'
        puts "  #{green('✓')} Content matches (all rows identical after sorting by coreid, type, ID)"
      else
        puts "  #{green('✓')} Content matches (all rows identical)"
      end
    end
  end

  def compare_xml(file1, file2, filename)
    if files_identical?(file1, file2)
      puts "  #{green('✓')} Files are identical"
      return
    end

    content1 = File.read(file1)
    content2 = File.read(file2)

    if filename == 'eml.xml'
      normalized1 = normalize_eml(content1)
      normalized2 = normalize_eml(content2)

      if normalized1 == normalized2
        puts "  #{green('✓')} Content matches (ignoring dynamic fields: packageId, dateStamp)"
        return
      end
    end

    if filename == 'meta.xml'
      removed_columns = ['UsageTerms', 'associatedObservationReference']
      if meta_xml_differs_only_by_removed_columns?(content1, content2, removed_columns)
        @warnings << "#{filename}: Field indices shifted due to removed columns: #{removed_columns.join(', ')}"
        puts "  #{yellow('⚠')} Field indices differ (due to removed columns: #{removed_columns.join(', ')})"
        puts "    Dir1 size: #{File.size(file1)} bytes"
        puts "    Dir2 size: #{File.size(file2)} bytes"
        return
      end
    end

    @differences << "#{filename}: XML files differ"
    puts "  #{red('✗')} Files differ"
    puts "    Dir1 size: #{File.size(file1)} bytes"
    puts "    Dir2 size: #{File.size(file2)} bytes"
    show_diff_sample(file1, file2)
  end

  def normalize_eml(content)
    content
      .gsub(/packageId="[^"]+"/, 'packageId="NORMALIZED"')
      .gsub(/<alternateIdentifier>[^<]+<\/alternateIdentifier>/, '<alternateIdentifier>NORMALIZED</alternateIdentifier>')
      .gsub(/<dateStamp>[^<]+<\/dateStamp>/, '<dateStamp>NORMALIZED</dateStamp>')
  end

  def meta_xml_differs_only_by_removed_columns?(content1, content2, removed_columns)
    removed_terms = {
      'UsageTerms' => 'http://ns.adobe.com/xap/1.0/rights/UsageTerms',
      'associatedObservationReference' => 'http://rs.tdwg.org/ac/terms/associatedObservationReference'
    }

    has_removed_1 = removed_columns.any? { |col| content1.include?(removed_terms[col]) }
    has_removed_2 = removed_columns.any? { |col| content2.include?(removed_terms[col]) }
    return false if has_removed_1 == has_removed_2

    normalized1 = normalize_meta_xml_for_removed_columns(content1, removed_terms.values)
    normalized2 = normalize_meta_xml_for_removed_columns(content2, removed_terms.values)
    normalized1 == normalized2
  end

  def normalize_meta_xml_for_removed_columns(content, removed_term_urls)
    result = content.dup
    removed_term_urls.each do |term_url|
      result.gsub!(/<field index="\d+" term="#{Regexp.escape(term_url)}"\/>\n\s*/, '')
    end

    field_index = 0
    result.gsub(/<field index="\d+"/) do
      replacement = "<field index=\"#{field_index}\""
      field_index += 1
      replacement
    end
  end

  def show_diff_sample(file1, file2)
    diff_output = `diff -u "#{file1}" "#{file2}" 2>&1 | head -20`
    return if diff_output.nil? || diff_output.empty?

    puts '    First few differences:'
    diff_output.lines[2..]&.each do |line|
      puts "    #{line.chomp}"
    end
  end

  def compare_binary(file1, file2, filename)
    if files_identical?(file1, file2)
      puts "  #{green('✓')} Files are identical"
      return
    end

    @differences << "#{filename}: Files differ"
    puts "  #{red('✗')} Files differ"
    puts "    Dir1 size: #{File.size(file1)} bytes"
    puts "    Dir2 size: #{File.size(file2)} bytes"
  end

  def files_identical?(file1, file2)
    Digest::SHA256.file(file1) == Digest::SHA256.file(file2)
  end

  def print_summary
    puts '=' * 80
    puts 'SUMMARY'
    puts '=' * 80

    if @differences.empty?
      if @warnings.any?
        puts green('✓ After accounting for the noted allowed differences, all files are identical!')
      else
        puts green('✓ All files are identical!')
      end
    else
      puts red("✗ Found #{@differences.size} difference(s):")
      @differences.each { |diff| puts "  - #{diff}" }
    end

    if @warnings.any?
      puts
      puts yellow('Warnings:')
      @warnings.each { |warning| puts "  #{yellow('!')} #{warning}" }
    end

    puts '=' * 80
    abort if @differences.any?
  end

  ########################################
  # data.tsv classification:
  #
  # a) identical file bytes => OK (handled in compare_tsv via files_identical?)
  # b) same rows after reordering => ERROR with note
  # c) not the same rows => ERROR
  # d) not the same rows, but UUID order is the same => ERROR
  #
  # Assumptions: TSV rows are single-line records (no embedded newlines).
  def compare_data_tsv_rowset(file1, file2, filename)
    puts "  Comparing data.tsv (this can take a bit)"

    # Context-only: header + row count info
    h1 = first_line_fields(file1)
    h2 = first_line_fields(file2)
    if h1 == h2
      puts "  #{green('✓')} Headers match (#{h1.size} columns)"
    else
      @differences << "#{filename}: Headers differ"
      puts "  #{red('✗')} Headers differ"
      puts "    Dir1 headers: #{h1.size} columns"
      puts "    Dir2 headers: #{h2.size} columns"
    end

    rows1 = [line_count_fast(file1) - 1, 0].max
    rows2 = [line_count_fast(file2) - 1, 0].max
    if rows1 == rows2
      puts "  #{green('✓')} Row count matches (#{rows1} rows)"
    else
      @differences << "#{filename}: Row count differs (#{rows1} vs #{rows2})"
      puts "  #{red('✗')} Row count differs: dir1=#{rows1}, dir2=#{rows2}"
      # Keep going: the sorted-row comparison will fall into (c)/(d) anyway.
    end

    tmp_dir = '/tmp'
    sorted1 = tmp_path('dwca_data_sorted', ext: 'tsv', tmp_dir: tmp_dir)
    sorted2 = tmp_path('dwca_data_sorted', ext: 'tsv', tmp_dir: tmp_dir)

    begin
      # Sort full data rows (excluding header) in a locale-stable way
      sort_data_rows_excluding_header(file1, sorted1, tmp_dir: tmp_dir)
      sort_data_rows_excluding_header(file2, sorted2, tmp_dir: tmp_dir)

      if system("cmp -s #{Shellwords.escape(sorted1)} #{Shellwords.escape(sorted2)}")
        # b) same rows after reordering
        @differences << "#{filename}: Same rows after row reordering (order-insensitive match)"
        puts "  #{red('✗')} Same rows after row reordering"
        puts "    Note: When sorted, all data rows match exactly; files differ only by row order."
        return
      end

      # If the row multisets differ, decide between (c) and (d) by checking UUID order.
      if uuid_order_is_identical?(file1, file2)
        # d) different rows, same UUID order
        @differences << "#{filename}: Not the same rows, but UUID order is the same"
        puts "  #{red('✗')} Not the same rows, but UUID order is the same"
        puts "    Note: UUID column (col 1) matches line-by-line, but full rows differ."
      else
        # c) different rows
        @differences << "#{filename}: Not the same rows (order-insensitive compare failed)"
        puts "  #{red('✗')} Not the same rows"
      end

      # Extract UUIDs of differing rows
      differing_uuids = extract_differing_uuids(sorted1, sorted2)

      if differing_uuids.any?
        display_limit = @show_all ? differing_uuids.size : 15
        displayed = [display_limit, differing_uuids.size].min

        puts "    Showing #{displayed} of #{differing_uuids.size} differing rows:"
        puts

        differing_uuids.take(display_limit).each do |uuid|
          show_row_differences(file1, file2, uuid, column_limit: display_limit)
          puts
        end

        if differing_uuids.size > display_limit
          puts "    ... and #{differing_uuids.size - display_limit} more differences"
          puts "    Run with 'all' parameter to see all differences:"
          puts "      rake tw:development:dwca:compare[path1,path2,all]"
        end
      end
    ensure
      FileUtils.rm_f(sorted1) rescue nil
      FileUtils.rm_f(sorted2) rescue nil
    end
  end

  def uuid_order_is_identical?(file1, file2)
    # Compare first column (UUID) line-by-line in order, skipping header.
    # We assume no embedded newlines, so split("\t", 2) is safe and fast.
    File.open(file1, 'rb') do |f1|
      File.open(file2, 'rb') do |f2|
        f1.gets
        f2.gets
        loop do
          l1 = f1.gets
          l2 = f2.gets
          return true if l1.nil? && l2.nil?
          return false if l1.nil? || l2.nil?

          u1 = l1.split("\t", 2).first
          u2 = l2.split("\t", 2).first
          return false if u1 != u2
        end
      end
    end
  end

  def sort_data_rows_excluding_header(input_path, output_path, tmp_dir:)
    cmd = %(bash -lc "LC_ALL=C sort -T #{Shellwords.escape(tmp_dir)} <(tail -n +2 #{Shellwords.escape(input_path)}) > #{Shellwords.escape(output_path)}")
    system(cmd) || raise("sort failed for #{input_path}")
  end

  def first_line_fields(path)
    File.open(path, 'rb') do |f|
      line = f.gets
      return [] unless line
      line.chomp.split("\t", -1)
    end
  end

  def line_count_fast(path)
    `wc -l #{Shellwords.escape(path)} 2>/dev/null`.to_i
  end

  def tmp_path(prefix, ext: 'txt', tmp_dir: '/tmp')
    File.join(tmp_dir, "#{prefix}_#{Process.pid}_#{SecureRandom.hex(6)}.#{ext}")
  end

  # Extract UUIDs of rows that differ between two sorted TSV files
  def extract_differing_uuids(sorted1, sorted2)
    uuids = []
    diff_output = `diff #{Shellwords.escape(sorted1)} #{Shellwords.escape(sorted2)} 2>&1`

    diff_output.lines.each do |line|
      # Lines starting with < or > contain actual row data
      if line.start_with?('< ') || line.start_with?('> ')
        uuid = line[2..].split("\t", 2).first
        uuids << uuid unless uuids.include?(uuid)
      end
    end

    uuids
  end

  # Show column-by-column differences for a specific UUID (row).
  def show_row_differences(file1, file2, uuid, column_limit: 10)
    h1, r1 = read_row(file1, uuid)
    h2, r2 = read_row(file2, uuid)

    return unless h1 && h2 && r1 && r2

    if h1 != h2
      puts "    #{yellow('⚠')} UUID: #{uuid} - Headers don't match, skipping detailed comparison"
      return
    end

    diffs = []
    h1.each_with_index do |name, i|
      a = r1[i] || ""
      b = r2[i] || ""
      diffs << [name, a, b] unless a == b
    end

    if diffs.empty?
      puts "    UUID: #{uuid} - No differences found"
      return
    end

    puts "    #{yellow('UUID:')} #{uuid}"
    puts "    #{yellow('Different columns:')} #{diffs.size}"
    if diffs.size > column_limit
      puts "    (showing first #{column_limit} column differences)"
    end
    puts "    #{'-' * 76}"

    diffs.take(column_limit).each do |name, a, b|
      puts "    #{name}"
      puts "      #{red('OLD:')} #{a.inspect}"
      puts "      #{green('NEW:')} #{b.inspect}"
    end

    puts "    #{'-' * 76}"
  end

  # Read a specific row from a TSV file by UUID
  def read_row(path, uuid)
    File.open(path, "r:bom|utf-8") do |f|
      header = f.gets&.chomp&.split("\t")
      return [nil, nil] unless header

      f.each_line do |line|
        cols = line.chomp.split("\t", -1) # keep trailing empties
        return [header, cols] if cols[0] == uuid
      end

      [nil, nil] # UUID not found
    end
  rescue => e
    puts "    #{red('Error reading row:')} #{e.message}"
    [nil, nil]
  end
end
