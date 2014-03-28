module GeoLocater
  # TODO: library (=> gem) to interact with geolocate (http://www.museum.tulane.edu/geolocate/default.html)

=begin
  What does a request to geolocate look like?
    -- construct URL (http://www.museum.tulane.edu/geolocate/images/webgeoreflight.png)

  What are the responses to be expected friom geolocate?
    -- things to look at:
        -- JSON
        -- GeoJSON
        -- SOAP
          -- http://www.museum.tulane.edu/geolocate/files/glcJSON.pdf
              http://www.museum.tulane.edu/webservices/geolocatesvcv2/glcwrap.aspx?Country=USA&Locality=stockton&state=ia
  How to build a gem out of this?
    -- look at Gaurav's biburi gem
=end

  URI_HOST = 'www.museum.tulane.edu'
  URI_PATH = '/webservices/geolocatesvcv2/glcwrap.aspx'
  uri_request = '?country=usa&locality=champaign&state=il&dopoly=true'
=begin

  Request = URI_HOST + URI_PATH + uri_request

  result = "
{
"engineVersion" : "GLC:4.93|U:1.01374|eng:1.0",
"numResults" : 1,
"executionTimems" : 140.4003,
"resultSet" : { "type": "FeatureCollection",
"features": [
{ "type": "Feature",
"geometry": {"type": "Point", "coordinates": [-88.24333, 40.11639]},
"properties": {
"parsePattern" : "CHAMPAIGN",
"precision" : "High",
"score" : 84,
"uncertaintyRadiusMeters" : 7338,
"uncertaintyPolygon" : {
"type": "Polygon",
"coordinates": [
[[-88.2699379175,40.1379180207], [-88.2694189175,40.1375100207], [-88.2694509175,40.1374060207], [-88.2690329175,40.1372730207], [-88.2689819175,40.1373630207], [-88.2689439175,40.1375880207], [-88.2688339175,40.1401300207], [-88.2691719175,40.1415490207], [-88.2691719175,40.1416530207], [-88.2691599175,40.1417120207], [-88.2691429175,40.1419090207], [-88.2695809175,40.1418370207], [-88.2695859175,40.1420250207], [-88.2693509175,40.1420950207], [-88.2693799175,40.1421570207], [-88.2692849175,40.1422310207], [-88.2691779175,40.1431160207], [-88.2696049175,40.1434840207], [-88.2697659175,40.1435510207], [-88.2702859175,40.1432970207], [-88.2712409175,40.1436270207], [-88.2711889175,40.1437380207], [-88.2699079175,40.1383270207], [-88.2701109175,40.1379790207], [-88.2699379175,40.1379180207]]]
},"displacedDistanceMiles" : 0,
"displacedHeadingDegrees" : 0,
"debug" : ":GazPartMatch=False|:inAdm=True|:Adm=CHAMPAIGN|:NPExtent=12182|:NP=CHAMPAIGN|:KFID=IL:ppl:5268|CHAMPAIGN"
}
}
 ],
"crs": { "type" : "EPSG", "properties" : { "code" : 4326 }}
}
}
"
  Things to store:

  request => text from '?' to end of request string
  country string
  state string
  county string
  locality string
  locality Point


  Things to build a request:

  request => text from '?' to end of request
  '?country=usa&locality=champaign&state=illinois&dopoly=true'

  locality => name of a place 'CHAMPAIGN' (or building, i.e. 'Eiffel Tower')
  country => name of a country 'USA', or Germany
  state => 'IL', or 'illinois' (required in the United States)
  county => supply as a parameter, returned as 'Adm='
  hwyX (boolean)
  enableH2O (boolean)
  doUncert (boolean)
  doPoly (boolean)
  displacePoly
  languageKey
  fmt => JSON or GeoJSON

=end


end
