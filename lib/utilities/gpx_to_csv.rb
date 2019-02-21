module Utilities::GPXToCSV

  # convert a GPX file to a bespoke tab-seperated CSV file

  # @param [GPX::GPXFile] gpx_file
  # @param [Hash] csv_options
  # @return [String]
  def self.gpx_to_csv(gpx_file, csv_options = {col_sep: "\t", headers: true, encoding: 'UTF-8', write_headers: true})
    gpx_headers = %w(name geojson start_date end_date)
    csv_string = CSV.generate do |csv|
      csv << gpx_headers

      gpx_file.waypoints.each do |waypoint|
        csv << [waypoint.name,
                "POINT(#{waypoint.lon} #{waypoint.lat} #{waypoint.ele})",
                '',
                '']
        csv
      end

      gpx_file.routes.each do |route|

      end

      gpx_file.tracks.each do |track|

      end
    end
    csv_string
  end
end

# gpx = GPX::GPXFile.new(:gpx_file => '/Users/tuckerjd/src/taxonworks/spec/files/batch/collecting_event/test.gpx')
# Utilities::GPXToCSV.gpx_to_csv(gpx)
