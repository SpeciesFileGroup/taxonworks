import Collectors from '../components/verbatim/Collectors.vue'
import CollectorsComponent from '../components/parsed/Collectors.vue'
import DateComponent from '../components/verbatim/Date.vue'
import Geolocation from '../components/verbatim/Geolocation.vue'
import Habitat from '../components/verbatim/Habitat.vue'
import Label from '../components/verbatim/Label.vue'
import Latitude from '../components/verbatim/Latitude.vue'
import Locality from '../components/verbatim/Locality.vue'
import Longitude from '../components/verbatim/Longitude.vue'
import Method from '../components/verbatim/Method.vue'
import TripIdentifier from '../components/verbatim/TripIdentifier.vue'
import Dates from '../components/parsed/Dates.vue'
import Elevation from '../components/parsed/Elevation.vue'
import GeographicArea from '../components/parsed/GeographicArea.vue'
import Group from '../components/parsed/Group.vue'
import Time from '../components/parsed/Time.vue'
import TripCode from '../components/parsed/TripCode.vue'
import Predicates from '../components/parsed/Predicates.vue'
import Georeferences from '../components/parsed/georeferences/georeferences.vue'
import VerbatimElevation from '../components/verbatim/Elevation'
import Datum from '../components/verbatim/Datum'

import MapComponent from '../components/map/Map.vue'
import PrintLabel from '../components/map/PrintLabel.vue'
import Depictions from '../components/map/Depictions.vue'

const ComponentVerbatim = {
  Label: 'Label',
  Locality: 'Locality',
  Latitude: 'Latitude',
  Longitude: 'Longitude',
  Geolocation: 'Geolocation',
  VerbatimElevation: 'VerbatimElevation',
  Habitat: 'Habitat',
  DateComponent: 'DateComponent',
  Datum: 'Datum',
  Collectors: 'Collectors',
  Method: 'Method',
  TripIdentifier: 'TripIdentifier'
}

const ComponentParse = {
  GeographicArea: 'GeographicArea',
  Georeferences: 'Georeferences',
  Dates: 'Dates',
  Elevation: 'Elevation',
  Time: 'Time',
  CollectorsComponent: 'CollectorsComponent',
  TripCode: 'TripCode',
  Group: 'Group',
  Predicates: 'Predicates'
}

const ComponentMap = {
  Map: 'Map',
  PrintLabel: 'PrintLabel',
  Depictions: 'Depictions'
}

const VueComponents = {
  [ComponentVerbatim.Collectors]: Collectors,
  [ComponentVerbatim.DateComponent]: DateComponent,
  [ComponentVerbatim.Geolocation]: Geolocation,
  [ComponentVerbatim.Collectors]: Collectors,
  [ComponentVerbatim.Habitat]: Habitat,
  [ComponentVerbatim.Label]: Label,
  [ComponentVerbatim.Latitude]: Latitude,
  [ComponentVerbatim.Locality]: Locality,
  [ComponentVerbatim.Longitude]: Longitude,
  [ComponentVerbatim.VerbatimElevation]: VerbatimElevation,
  [ComponentVerbatim.Datum]: Datum,
  [ComponentVerbatim.Method]: Method,
  [ComponentVerbatim.TripIdentifier]: TripIdentifier,
  [ComponentParse.Dates]: Dates,
  [ComponentParse.Elevation]: Elevation,
  [ComponentParse.GeographicArea]: GeographicArea,
  [ComponentParse.Georeferences]: Georeferences,
  [ComponentParse.Group]: Group,
  [ComponentParse.CollectorsComponent]: CollectorsComponent,
  [ComponentParse.Time]: Time,
  [ComponentParse.TripCode]: TripCode,
  [ComponentParse.Predicates]: Predicates,
  [ComponentMap.PrintLabel]: PrintLabel,
  [ComponentMap.Map]: MapComponent,
  [ComponentMap.Depictions]: Depictions
}

export {
  ComponentVerbatim,
  ComponentParse,
  ComponentMap,
  VueComponents
}
