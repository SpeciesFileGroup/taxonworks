module GPXToCSV

  # convert a GPX file to a bespoke tab-seperated CSV file

  # @param [GPX::GPXFile] gpx_file
  # @param [Hash] csv_options
  # @return [CSV]
  def self.gpx_to_csv(gpx_file, csv_options = {col_sep: "\t", headers: true, encoding: 'UTF-8', write_headers: true})
    gpx_headers = %w(name geojson start_date end_date minimum_elevation maximum_elevation)

    csv_string = CSV.generate(csv_options) do |csv|
      csv << gpx_headers
      geo_feature = {'type': 'Feature', 'geometry': '{}'}

      gpx_file.waypoints.each do |waypoint|
        json = {'type': 'Point', 'coordinates': [waypoint.lon, waypoint.lat]}
        geo_feature[:geometry] = json
        csv << [waypoint.name, geo_feature.to_json, nil, nil, waypoint.elevation, nil]
        csv
      end

      gpx_file.routes.each do |route|
        start_time = route.points.first.time
        end_time = route.points.last.time
        coordinates = []

        route.points.each do |point|
          coordinates << [point.lon, point.lat]
        end

        json = {'type': 'LineString', 'coordinates': coordinates}
        geo_feature[:geometry] = json

        csv << [
          route.name,
          geo_feature.to_json,
          start_time,
          end_time,
          min_elev,
          max_elev
        ]
      end

      gpx_file.tracks.each do |track|
        start_time = track.points.first.time
        end_time = track.points.last.time
        coordinates = []

        min_elev = nil
        max_elev = nil

        track.points.each do |point|
          if point.elevation
            min_elev = point.elevation if min_elev.nil? || point.elevation < min_elev

            if min_elev && min_elev != point.elevation
              max_elev ||= 0
              max_elev = point.elevation if max_elev < point.elevation
            end
          end

          coordinates << [point.lon, point.lat]

        end
        json = {'type': 'LineString', 'coordinates': coordinates}
        geo_feature[:geometry] = json

        csv << [track.name,
                geo_feature.to_json,
                start_time,
                end_time,
                min_elev,
                max_elev]
      end
    end
    csv = CSV.parse(csv_string, csv_options)
    csv
  end
end
