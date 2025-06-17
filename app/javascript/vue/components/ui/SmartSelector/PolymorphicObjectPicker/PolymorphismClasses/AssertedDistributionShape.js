import { Gazetteer, GeographicArea } from "@/routes/endpoints"

export default [
  // Default first.
  {
    singular: 'GeographicArea',
    plural: 'GeographicAreas',
    human: 'geographic area',
    display: 'Geographic area',
    snake: 'geographic_areas',
    endpoint: GeographicArea,
    query_key: 'geographic_area_id',
  },

  {
    singular: 'Gazetteer',
    plural: 'Gazetteers',
    human: 'gazetteer',
    display: 'Gazetteer',
    snake: 'gazetteers',
    endpoint: Gazetteer,
    query_key: 'gazetteer_id',
  },

]