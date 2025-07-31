module Export::CSV::BiologicalAssociations::Extended

  HEADERS = %I{
    id
    subject_order
    subject_family
    subject_genus
    subject
    subject_id
    subject_properties
    subject_taxon_name_id
    subject_type
    biological_relationship_id
    biological_relationships
    object_properties
    object_taxon_name_id
    object_type
    object
    object_id
    object_order
    object_family
    object_genus
  }.freeze

  def self.csv(biological_associations)

    data = ApplicationController.helpers.extended_hash(biological_associations)

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
