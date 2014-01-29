module Utilities::Csv

  # A dirt simple CSV dump to STDOUT.
  # TODO: 
  #   - optionify
  #   - validate object collection is uniformly classed (all the same)
  def self.to_csv(objects)
    return if objects.size == 0
    column_names = objects.first.class.column_names
    string = CSV.generate do |csv|
      csv << column_names
      objects.each do |o|
        csv << o.attributes.values_at(*column_names)
      end
    end
    puts string
  end

end
