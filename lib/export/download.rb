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

    headers = CSV::Row.new(h.headers, h.headers, true)

    tbl = CSV::Table.new([headers])

    # Pluck rows is from postgresql_cursor gem
    scope.pluck_rows(*column_names).each do |o|
      tbl << o.collect{|v| Utilities::Strings.sanitize_for_csv(v) }
      # If keys are not deterministic: .attributes.values_at(*column_names).collect{|v| Utilities::Strings.sanitize_for_csv(v) }
    end

    delete_columns(tbl, exclude_columns) if !exclude_columns.empty?
    trim_columns(tbl) if trim_columns
    trim_rows(tbl) if trim_rows

    # CSV::Converters are only available on read, not generate, so we can't use them here.
    tbl.to_csv(col_sep: "\t", encoding: Encoding::UTF_8)
  end

    # @param table [CSV::Table]
    # @param columns [Array]
    # @return [CSV::Table]
    #   delete the specified columns
  def self.delete_columns(tbl, columns = [])
    return tbl if columns.empty?
    columns.each do |col|
      tbl.delete(col.to_s)
    end
   tbl
  end

    # @return [CSV::Table]
    # @param table [CSV::Table]
    # @param skip_id [Boolean] if true ignore the 'id'l column in consideration of whether to delete this row
    #   delete rows if there are no values in any cell (of course doing this in the scope is better!)
  def self.trim_rows(table, skip_id = true)
    headers = table.headers
    headers = headers - ['id'] if skip_id
    table.by_row!.delete_if do |row|
      d = true
      headers.each do |h|
        next if row[h].blank?
        d = false
        break
      end
      d
    end
    table
  end

    # @return [CSV::Table]
    # @param table [CSV::Table]
    #   remove columns without any non-#blank? values (of course doing this in the scope is better!)
  def self.trim_columns(table)
    table.by_col!.delete_if do |h, col|
      d = true
      col.shift
      col.each do |v|
        next if v.blank?
        d = false
        break
      end
      d
    end
    table
  end

end

