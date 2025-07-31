module Utilities::CSV

  # A dirt simple CSV dump to STDOUT, tab separators. Takes an
  # array of AR instances.
  # TODO:
  #   - validate object collection is uniformly classed (all the same)
  # @param [Array] of objects
  # @param [Hash] of options
  def self.to_csv(objects, options = {col_sep: "\t", headers: true, encoding: 'UTF-8'})
    return if objects.size == 0
    column_names = objects.first.class.column_names
    string       = CSV.generate(options) do |csv|
      csv << column_names
      objects.each do |o|
        csv << o.attributes.values_at(*column_names)
      end
    end
    puts string
  end
end
