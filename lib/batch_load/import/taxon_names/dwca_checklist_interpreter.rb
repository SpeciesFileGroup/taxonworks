module BatchLoad
  class Import::TaxonNames::DwcaChecklistInterpreter < BatchLoad::Import
    NAME_COMPONENTS = ['infraspecificepithet', 'specificepithet', 'subgenus', 'genus', 'scientificname']

    def initialize(**args)
      @taxon_names = {}
      super(args)
    end

    def _build_taxon_names(records, parent)
      records.each do |record|
        begin
          protonym_attributes = {
            name: record[:row][NAME_COMPONENTS.detect { |x| !record[:row][x].blank? }],
            parent: parent,
            rank_class: Ranks.lookup(:iczn, record[:row]['taxonrank']),
            by: @user,
            also_create_otu: false,
            project: @project,
            verbatim_author: record[:row]['scientificnameauthorship']
          }

          protonym_attributes[:year_of_publication] = $1 if /(\s\d{4})(?!.*\d+)/ =~ protonym_attributes[:verbatim_author]

          parse_result = BatchLoad::RowParse.new
          name = Protonym.new(protonym_attributes)
          parse_result.objects[:taxon_name] = [name]

          if "typeGenus" == record[:row]["typestatus"]

          end

          @processed_rows[record[:rowno]] = parse_result

          @total_data_lines += 1

          _build_taxon_names(record[:children], name)
        rescue Exception => ex
          ap ex
        end
      end
    end

    def build_taxon_names
      @total_data_lines = 0
      i = 0

      # build records tree
      records = {}
      csv.each do |row|
        i += 1
        raise "Duplicated taxonID #{row["taxonid"]}." unless records[row["taxonid"]].nil?
        # Build records LUT
        records[row["taxonid"]] = { row: row, rowno: i, children: [] }
      end

      records.each do |k, v|
        if not v[:row]["parentnameusageid"].blank?
          if records[v[:row]["parentnameusageid"]].nil?
            raise "Invalid parentNameUsageID #{v[:row]["parentnameusageid"]} points to no record within this dataset."
          end

          parent = records[v[:row]["parentnameusageid"]]

          parent[:children] << v
          v[:parent] = parent
        end
      end

      records = records.values.select { |v| v[:row]["parentnameusageid"].blank? }

      # loop through rows

      _build_taxon_names(records, Project.find(@project_id).root_taxon_name)

      @total_lines = i
    end

    def build
      if valid?
        build_taxon_names
        @processed = true
      end
    end
  end
end
