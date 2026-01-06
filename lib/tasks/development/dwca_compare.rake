namespace :tw do
  namespace :development do
    namespace :dwca do
      desc 'Compare two DwCA export directories or zip files for differences'
      task :compare, [:path1, :path2] => [:environment] do |_t, args|
        require 'csv'
        require 'digest'
        require 'zip'
        require 'tmpdir'

        if args[:path1].nil? || args[:path2].nil?
          puts "Usage: rake tw:development:dwca:compare[path1,path2]"
          puts
          puts "Compare DwCA exports from two directories or zip files."
          puts "Arguments can be directories with unzipped DwCA files or .zip files."
          puts
          puts "Examples:"
          puts "  rake tw:development:dwca:compare[/path/to/export1,/path/to/export2]"
          puts "  rake tw:development:dwca:compare[/path/to/export1.zip,/path/to/export2.zip]"
          puts "  rake tw:development:dwca:compare[/path/to/export1,/path/to/export2.zip]"
          exit 1
        end

        comparer = DwcaComparer.new(args[:path1], args[:path2])
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
  def initialize(path1, path2)
    @path1 = File.expand_path(path1)
    @path2 = File.expand_path(path2)
    @differences = []
    @warnings = []
    @temp_dirs = []

    # Determine if paths are zip files or directories
    @dir1 = prepare_directory(@path1, 'dir1')
    @dir2 = prepare_directory(@path2, 'dir2')
  end

  def compare
    validate_directories

    puts "=" * 80
    puts "Comparing DwCA Exports"
    puts "=" * 80
    puts "Directory 1: #{@dir1}"
    puts "Directory 2: #{@dir2}"
    puts "=" * 80
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
  def green(text)
    "\e[32m#{text}\e[0m"
  end

  def yellow(text)
    "\e[33m#{text}\e[0m"
  end

  def red(text)
    "\e[31m#{text}\e[0m"
  end

  def prepare_directory(path, label)
    unless File.exist?(path)
      abort("Error: Path does not exist: #{path}")
    end

    if File.directory?(path)
      # Already a directory, use as-is
      path
    elsif File.file?(path) && path.end_with?('.zip')
      # Zip file - extract to temp directory
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
        dest_path = File.join(temp_dir, entry.name)
        FileUtils.mkdir_p(File.dirname(dest_path))
        entry.extract(dest_path)
      end
    end

    temp_dir
  end

  def validate_directories
    unless Dir.exist?(@dir1)
      abort("Error: Directory does not exist: #{@dir1}")
    end
    unless Dir.exist?(@dir2)
      abort("Error: Directory does not exist: #{@dir2}")
    end
  end

  def compare_file_lists(files1, files2)
    missing_in_dir2 = files1 - files2
    missing_in_dir1 = files2 - files1

    if missing_in_dir2.any?
      @differences << "Files in dir1 but not in dir2: #{missing_in_dir2.join(', ')}"
    end

    if missing_in_dir1.any?
      @differences << "Files in dir2 but not in dir1: #{missing_in_dir1.join(', ')}"
    end
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

    # Detailed comparison
    csv1 = CSV.read(file1, col_sep: "\t", headers: true, encoding: 'UTF-8')
    csv2 = CSV.read(file2, col_sep: "\t", headers: true, encoding: 'UTF-8')

    # Compare headers
    if csv1.headers != csv2.headers
      missing_in_2 = csv1.headers - csv2.headers
      missing_in_1 = csv2.headers - csv1.headers

      # Special case: Check if the only differences are removed deprecated columns
      # that were empty in the original export
      removed_columns = ['UsageTerms', 'associatedObservationReference']
      is_removed_columns_case = (
        filename == 'media.tsv' &&
        (missing_in_2.sort == removed_columns.sort || missing_in_1.sort == removed_columns.sort)
      )

      if is_removed_columns_case
        # Check if the removed columns were empty in the export that has them
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

          if missing_in_2.any?
            puts "    Columns in dir1 but not dir2: #{missing_in_2.join(', ')}"
          end
          if missing_in_1.any?
            puts "    Columns in dir2 but not dir1: #{missing_in_1.join(', ')}"
          end
        end
      else
        @differences << "#{filename}: Headers differ"
        puts "  #{red('✗')} Headers differ"
        puts "    Dir1 headers: #{csv1.headers.size} columns"
        puts "    Dir2 headers: #{csv2.headers.size} columns"

        if missing_in_2.any?
          puts "    Columns in dir1 but not dir2: #{missing_in_2.join(', ')}"
        end
        if missing_in_1.any?
          puts "    Columns in dir2 but not dir1: #{missing_in_1.join(', ')}"
        end
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

    # Try to compare content by sorting (if there's an 'id' or first column)
    compare_tsv_content(csv1, csv2, filename)
  end

  def compare_tsv_content(csv1, csv2, filename)
    # Find a key column to sort by (prefer 'id', 'coreid', 'occurrenceID', or first column)
    key_col = csv1.headers.find { |h| h =~ /^(id|coreid|occurrenceID)$/i } || csv1.headers.first

    return unless key_col

    # For media.tsv, sort by coreid, dc:type (Image/Sound), then providerManagedID
    # For other files, compare as-is to detect ordering issues
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

    # Compare rows
    max_rows = [rows1.size, rows2.size].max
    diff_count = 0
    nil_vs_empty_count = 0
    sample_diffs = []

    max_rows.times do |i|
      row1 = rows1[i]
      row2 = rows2[i]

      if row1.nil?
        diff_count += 1
        if sample_diffs.size < 5
          sample_diffs << "  Row only in dir2: #{key_col}=#{row2[key_col]}"
        end
      elsif row2.nil?
        diff_count += 1
        if sample_diffs.size < 5
          sample_diffs << "  Row only in dir1: #{key_col}=#{row1[key_col]}"
        end
      elsif row1.to_h != row2.to_h
        # Get common headers between both rows
        common_headers = row1.headers & row2.headers

        # Check if differences are only nil vs empty string, or in removed columns
        is_only_empty_diff = true
        common_headers.each do |header|
          v1 = row1[header]
          v2 = row2[header]
          next if v1 == v2
          # Check if one is nil and the other is empty string
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
          # Show which fields differ (only common headers with actual differences)
          common_headers.each do |header|
            v1 = row1[header]
            v2 = row2[header]
            # Skip if values are equal (including both being nil/empty)
            next if v1 == v2
            next if (v1.nil? || v1 == '') && (v2.nil? || v2 == '')

            sample_diffs << "    #{header}: '#{v1}' vs '#{v2}'"
          end
        end
      end
    end

    # Report nil vs empty string differences as a warning
    if nil_vs_empty_count > 0
      @warnings << "#{filename}: #{nil_vs_empty_count} rows have nil vs empty string differences"
      puts "  #{yellow('⚠')} #{nil_vs_empty_count} row(s) have nil vs empty string differences (not counted as errors)"
    end

    # Check for row ordering differences (same content, different order)
    if sorted_comparison && diff_count == 0
      # Compare unsorted to see if order differs
      unsorted_diff = false
      csv1.size.times do |i|
        if csv1[i].to_h != csv2[i].to_h
          unsorted_diff = true
          break
        end
      end

      if unsorted_diff
        if nil_vs_empty_count > 0
          @warnings << "#{filename}: Row order differs (content matches when sorted, ignoring nil/empty)"
          puts "  #{yellow('⚠')} Row order differs (content matches after sorting)"
        else
          @warnings << "#{filename}: Row order differs (content is identical when sorted)"
          puts "  #{yellow('⚠')} Row order differs (content matches after sorting)"
        end
      end
    end

    if diff_count > 0
      @differences << "#{filename}: #{diff_count} rows differ"
      puts "  #{red('✗')} Content differs: #{diff_count} row(s) differ"

      if sample_diffs.any?
        puts "  Sample differences (first 5):"
        sample_diffs.each { |diff| puts diff }
      end
      if diff_count > 5
        puts "  ... and #{diff_count - 5} more differences"
      end
    else
      if filename == 'media.tsv'
        if nil_vs_empty_count > 0
          puts "  #{green('✓')} Content matches after sorting (ignoring nil/empty differences)"
        else
          puts "  #{green('✓')} Content matches (all rows identical after sorting by coreid, type, ID)"
        end
      else
        if nil_vs_empty_count > 0
          puts "  #{green('✓')} Content matches (ignoring nil/empty differences)"
        else
          puts "  #{green('✓')} Content matches (all rows identical)"
        end
      end
    end
  end

  def compare_xml(file1, file2, filename)
    if files_identical?(file1, file2)
      puts "  #{green('✓')} Files are identical"
      return
    end

    # Check for known dynamic content
    content1 = File.read(file1)
    content2 = File.read(file2)

    # For EML files, try normalizing known dynamic fields
    if filename == 'eml.xml'
      normalized1 = normalize_eml(content1)
      normalized2 = normalize_eml(content2)

      if normalized1 == normalized2
        puts "  #{green('✓')} Content matches (ignoring dynamic fields: packageId, dateStamp)"
        return
      end
    end

    # For meta.xml, check if differences are only due to removed columns
    if filename == 'meta.xml'
      removed_columns = ['UsageTerms', 'associatedObservationReference']
      if meta_xml_differs_only_by_removed_columns?(content1, content2, removed_columns)
        @warnings << "#{filename}: Field indices shifted due to removed columns: #{removed_columns.join(', ')}"
        puts "  #{yellow('⚠')} Field indices differ (due to removed columns: #{removed_columns.join(', ')})"
        size1 = File.size(file1)
        size2 = File.size(file2)
        puts "    Dir1 size: #{size1} bytes"
        puts "    Dir2 size: #{size2} bytes"
        return
      end
    end

    @differences << "#{filename}: XML files differ"
    puts "  #{red('✗')} Files differ"

    # Show size difference
    size1 = File.size(file1)
    size2 = File.size(file2)
    puts "    Dir1 size: #{size1} bytes"
    puts "    Dir2 size: #{size2} bytes"

    # Show a diff sample
    show_diff_sample(file1, file2)
  end

  def normalize_eml(content)
    # Normalize known dynamic fields in EML files
    content
      .gsub(/packageId="[^"]+"/, 'packageId="NORMALIZED"')
      .gsub(/<alternateIdentifier>[^<]+<\/alternateIdentifier>/, '<alternateIdentifier>NORMALIZED</alternateIdentifier>')
      .gsub(/<dateStamp>[^<]+<\/dateStamp>/, '<dateStamp>NORMALIZED</dateStamp>')
  end

  def meta_xml_differs_only_by_removed_columns?(content1, content2, removed_columns)
    # Check if one file has the removed column terms and the other doesn't
    removed_terms = {
      'UsageTerms' => 'http://ns.adobe.com/xap/1.0/rights/UsageTerms',
      'associatedObservationReference' => 'http://rs.tdwg.org/ac/terms/associatedObservationReference'
    }

    # Check if removed columns exist in one but not the other
    has_removed_1 = removed_columns.any? { |col| content1.include?(removed_terms[col]) }
    has_removed_2 = removed_columns.any? { |col| content2.include?(removed_terms[col]) }

    # If both have them or neither has them, this isn't about removed columns
    return false if has_removed_1 == has_removed_2

    # Normalize by removing the removed column fields and renumbering indices
    normalized1 = normalize_meta_xml_for_removed_columns(content1, removed_terms.values)
    normalized2 = normalize_meta_xml_for_removed_columns(content2, removed_terms.values)

    normalized1 == normalized2
  end

  def normalize_meta_xml_for_removed_columns(content, removed_term_urls)
    # Remove field elements for removed columns
    result = content.dup
    removed_term_urls.each do |term_url|
      result.gsub!(/<field index="\d+" term="#{Regexp.escape(term_url)}"\/>\n\s*/, '')
    end

    # Renumber all field indices sequentially
    field_index = 0
    result.gsub(/<field index="\d+"/) do |match|
      replacement = "<field index=\"#{field_index}\""
      field_index += 1
      replacement
    end
  end

  def show_diff_sample(file1, file2)
    # Use diff command to show a sample of differences
    diff_output = `diff -u "#{file1}" "#{file2}" 2>&1 | head -20`
    if diff_output && !diff_output.empty?
      puts "    First few differences:"
      diff_output.lines[2..-1]&.each do |line|
        puts "    #{line.chomp}"
      end
    end
  end

  def compare_binary(file1, file2, filename)
    if files_identical?(file1, file2)
      puts "  #{green('✓')} Files are identical"
      return
    end

    @differences << "#{filename}: Files differ"
    puts "  #{red('✗')} Files differ"

    size1 = File.size(file1)
    size2 = File.size(file2)
    puts "    Dir1 size: #{size1} bytes"
    puts "    Dir2 size: #{size2} bytes"
  end

  def files_identical?(file1, file2)
    Digest::SHA256.file(file1) == Digest::SHA256.file(file2)
  end

  def print_summary
    puts "=" * 80
    puts "SUMMARY"
    puts "=" * 80

    if @differences.empty?
      if @warnings.any?
        puts green("✓ After accounting for the noted allowed differences, all files are identical!")
      else
        puts green("✓ All files are identical!")
      end
    else
      puts red("✗ Found #{@differences.size} difference(s):")
      @differences.each do |diff|
        puts "  - #{diff}"
      end
    end

    if @warnings.any?
      puts
      puts yellow("Warnings:")
      @warnings.each do |warning|
        puts "  #{yellow('!')} #{warning}"
      end
    end

    puts "=" * 80

    abort if @differences.any?
  end
end
