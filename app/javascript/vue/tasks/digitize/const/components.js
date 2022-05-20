import Collectors from '../components/collectingEvent/components/verbatim/collectors.vue'
import Label from '../components/collectingEvent/components/verbatim/label.vue'
import DateComponent from '../components/collectingEvent/components/verbatim/date.vue'
import Datum from '../components/collectingEvent/components/verbatim/datum.vue'
import VerbatimElevation from '../components/collectingEvent/components/verbatim/elevation.vue'
import TripIdentifier from '../components/collectingEvent/components/verbatim/tripIdentifier.vue'
import Geolocation from '../components/collectingEvent/components/verbatim/geolocationUncertainty.vue'
import Habitat from '../components/collectingEvent/components/verbatim/habitat.vue'
import Latitude from '../components/collectingEvent/components/verbatim/latitude.vue'
import Locality from '../components/collectingEvent/components/verbatim/locality.vue'
import Longitude from '../components/collectingEvent/components/verbatim/longitude.vue'
import Method from '../components/collectingEvent/components/verbatim/method.vue'

import GeographicArea from '../components/collectingEvent/components/geography/geography.vue'
import Georeferences from '../components/collectingEvent/components/geography/georeferences.vue'
import Elevation from '../components/collectingEvent/components/geography/elevation.vue'
import Dates from '../components/collectingEvent/components/geography/dates.vue'
import Time from '../components/collectingEvent/components/geography/times.vue'
import Group from '../components/collectingEvent/components/geography/group.vue'
import CollectorsComponent from '../components/collectingEvent/components/geography/collectors.vue'
import Predicates from '../components/collectingEvent/components/geography/predicates.vue'
import TripCode from '../components/collectingEvent/components/geography/tripCode.vue'

import MapComponent from '../components/collectingEvent/components/map/map.vue'
import PrintLabel from '../components/collectingEvent/components/map/printLabel'
import SoftValidation from 'components/soft_validations/panel'
import Depictions from '../components/collectingEvent/components/map/depictions'

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
  TripIdentifier: 'TripIdentifier',
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
  SoftValidation: 'SoftValidation',
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
  [ComponentMap.SoftValidation]: SoftValidation,
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
