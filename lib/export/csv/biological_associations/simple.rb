module Export::CSV::BiologicalAssociations::Simple

  HEADERS = %I{
    subject_order
    subject_family
    subject_genus
    subject
    subject_properties
    biological_relationships
    object_properties
    object
    object_order
    object_family
    object_genus
  }.freeze

  def self.csv(biological_associations)

    data = ApplicationController.helpers.simple_hash(biological_associations)

    tbl = []
    tbl[0] = HEADERS.map(&:to_s)

    data.each do |h|
      tbl << HEADERS.collect{|c| h[c]}
    end

    output = StringIO.new
    tbl.each do |row|
      output.puts ::CSV.generate_line(row, col_sep: "\t", encoding: Encoding::UTF_8)
    end

    output.string
  end

end
