export const verbatimProperties = {
  Datum: 'verbatim_datum',
  Label: 'verbatim_label',
  Locality: 'verbatim_locality',
  Latitude: 'verbatim_latitude',
  Longitude: 'verbatim_longitude',
  Geolocation: (ce) => ce.verbatim_geolocation_uncertainty ? `+/-${ce.verbatim_geolocation_uncertainty}m` : undefined,
  Habitat: 'verbatim_habitat',
  DateComponent: 'verbatim_date',
  Collectors: 'verbatim_collectors',
  Method: 'verbatim_method',
  TripIdentifier: 'verbatim_trip_identifier'
}
