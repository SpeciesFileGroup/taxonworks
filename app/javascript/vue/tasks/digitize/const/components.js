import Collectors from '../components/collectionEvent/components/verbatim/collectors.vue'
import Label from '../components/collectionEvent/components/verbatim/label.vue'
import DateComponent from '../components/collectionEvent/components/verbatim/date.vue'
import Datum from '../components/collectionEvent/components/verbatim/datum.vue'
import VerbatimElevation from '../components/collectionEvent/components/verbatim/elevation.vue'
import Geolocation from '../components/collectionEvent/components/verbatim/geolocationUncertainty.vue'
import Habitat from '../components/collectionEvent/components/verbatim/habitat.vue'
import Latitude from '../components/collectionEvent/components/verbatim/latitude.vue'
import Locality from '../components/collectionEvent/components/verbatim/locality.vue'
import Longitude from '../components/collectionEvent/components/verbatim/longitude.vue'
import Method from '../components/collectionEvent/components/verbatim/method.vue'

import GeographicArea from '../components/collectionEvent/components/geography/geography.vue'
import Georeferences from '../components/collectionEvent/components/geography/georeferences.vue'
import Elevation from '../components/collectionEvent/components/geography/elevation.vue'
import Dates from '../components/collectionEvent/components/geography/dates.vue'
import Time from '../components/collectionEvent/components/geography/times.vue'
import Group from '../components/collectionEvent/components/geography/group.vue'
import CollectorsComponent from '../components/collectionEvent/components/geography/collectors.vue'
import Predicates from '../components/collectionEvent/components/geography/predicates.vue'
import TripCode from '../components/collectionEvent/components/geography/tripCode.vue'

import MapComponent from '../components/collectionEvent/components/map/map.vue'
import PrintLabel from '../components/collectionEvent/components/map/printLabel'
import SoftValidation from 'components/soft_validations/panel'
import Depictions from '../components/collectionEvent/components/map/depictions'

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
  Method: 'Method'
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
  SoftValidation: 'SoftValidation',
  Map: 'Map',
  PrintLabel: 'PrintLabel',
  Depictions: 'Depictions'
}

const VueComponents = {
  [ComponentVerbatim.Collectors]: Collectors,
  [ComponentVerbatim.Geolocation]: Geolocation,
  [ComponentVerbatim.Collectors]: Collectors,
  [ComponentVerbatim.Habitat]: Habitat,
  [ComponentVerbatim.Label]: Label,
  [ComponentVerbatim.Latitude]: Latitude,
  [ComponentVerbatim.Locality]: Locality,
  [ComponentVerbatim.Longitude]: Longitude,
  [ComponentVerbatim.VerbatimElevation]: VerbatimElevation,
  [ComponentVerbatim.DateComponent]: DateComponent,
  [ComponentVerbatim.Datum]: Datum,
  [ComponentVerbatim.Method]: Method,
  [ComponentParse.Dates]: Dates,
  [ComponentParse.Elevation]: Elevation,
  [ComponentParse.GeographicArea]: GeographicArea,
  [ComponentParse.Georeferences]: Georeferences,
  [ComponentParse.Group]: Group,
  [ComponentParse.CollectorsComponent]: CollectorsComponent,
  [ComponentParse.Time]: Time,
  [ComponentParse.TripCode]: TripCode,
  [ComponentParse.Predicates]: Predicates,
  [ComponentMap.SoftValidationComponent]: SoftValidation,
  [ComponentMap.PrintLabel]: PrintLabel,
  [ComponentMap.Map]: MapComponent,
  [ComponentMap.Depictions]: Depictions
}

export {
  VueComponents,
  ComponentVerbatim,
  ComponentParse,
  ComponentMap
}
