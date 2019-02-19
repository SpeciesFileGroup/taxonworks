module Utilities::GPXToCSV

  # convert a GPX file to a bespoke tab-seperated CSV file

  def self.gpx_to_csv(gpx_file, options = {col_sel: "\t", headers: true, encoding: 'UTF-8'})
    csv = CSV.new()
    headers = %w(name geojson start_date, end_date)

    gpx.waypoints.each do |waypoint|

    end
  end
end
