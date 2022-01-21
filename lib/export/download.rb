# Code that translates scopes into downloadable tab-delimited CSV. Dependant on Postgresql.
#
module Export::Download

  #   translate a scope into a CSV table, with optional tweaks to the data
  #
  # This is a very nice reference for future consideration:
  #   http://collectiveidea.com/blog/archives/2015/03/05/optimizing-rails-for-memory-usage-part-3-pluck-and-database-laziness
  # @param [Scope] scope
  # @param [Array] exclude_columns
  # @param [Array] header_converters
  # @param [Boolean] trim_rows
  # @param [Boolean] trim_columns
  # @return [CSV]
  def self.generate_csv(scope, exclude_columns: [], header_converters: [], trim_rows: false, trim_columns: false)
    # Check to see if keys is deterministicly ordered
    column_names = scope.columns_hash.keys

    h = CSV.new(column_names.join(','), header_converters: header_converters, headers: true)
    h.read

    headers = CSV::Row.new(h.headers, h.headers, true).headers

    tbl = headers.map { |h| [h] }

    # Pluck rows is from postgresql_cursor gem
    #puts Rainbow('preparing data: ' + (Benchmark.measure do
    scope.pluck_rows(*column_names).each do |o|
        o.each_with_index do |value, index|
        tbl[index] << Utilities::Strings.sanitize_for_csv(value)
      end
      # If keys are not deterministic: .attributes.values_at(*column_names).collect{|v| Utilities::Strings.sanitize_for_csv(v) }
    end
    # end).to_s).yellow

    if !exclude_columns.empty?
      # puts Rainbow('deleting columns: ' + (Benchmark.measure {
      delete_columns(tbl, exclude_columns)
      # }).to_s).yellow
    end

    if trim_columns
      # puts Rainbow('trimming columns: ' + (Benchmark.measure {
      trim_columns(tbl)
      # }).to_s).yellow
    end

    # CSV::Converters are only available on read, not generate, so we can't use them here.
    output = StringIO.new
    # puts Rainbow('generating CSV: '+ (Benchmark.measure do
    (0..tbl.first.length-1).each do |row_index|
      row = tbl.collect { |c| c[row_index] }
      if trim_rows
        next unless row.detect { |c| c.present? }
      end
      output.puts CSV.generate_line(row, col_sep: "\t", encoding: Encoding::UTF_8)
    end
    # end).to_s).yellow

    output.string
  end

  # @param table [Array]
  # @param columns [Array]
  # @return [Array]
  #   delete the specified columns
  def self.delete_columns(tbl, columns = [])
    headers = tbl.collect { |c| c.first }

    columns.each do |col|
      tbl.delete_at(headers.index(col.to_s))
    end
    tbl
  end

  # @return [Array]
  # @param table [Array]
  #   remove columns without any non-#blank? values (of course doing this in the scope is better!)
  #   this is very slow, use a proper scope, and exclude_columns: [] options instead    
  def self.trim_columns(table)
    to_delete = []

    table.each_with_index do |col, index|
      to_delete << index unless col.inject { |_, c| break true if !c.blank? }
    end

    to_delete.each_with_index { |x, i| table.delete_at(x-i) }
    table
  end

end

