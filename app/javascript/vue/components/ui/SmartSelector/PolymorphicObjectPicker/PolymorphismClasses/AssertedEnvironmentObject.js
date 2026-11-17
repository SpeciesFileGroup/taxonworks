import { CollectingEvent, Gazetteer, Otu } from '@/routes/endpoints'

// Must stay in sync with ENVIRONMENT_ASSERTABLE_TYPES
const AssertedEnvironmentObject = [
  // Default first.
  {
    singular: 'Otu',
    plural: 'Otus',
    human: 'OTU',
    display: 'OTU',
    snake: 'otus',
    endpoint: Otu,
    query_key: 'otu_id',
    searchbox_text: 'Search for an OTU',
    smartSelector: {
      props: {
        otuPicker: true
      }
    }
  },

  {
    singular: 'CollectingEvent',
    plural: 'CollectingEvents',
    human: 'collecting event',
    display: 'Collecting event',
    snake: 'collecting_events',
    endpoint: CollectingEvent,
    query_key: 'collecting_event_id'
  },

  {
    singular: 'Gazetteer',
    plural: 'Gazetteers',
    human: 'gazetteer',
    display: 'Gazetteer',
    snake: 'gazetteers',
    endpoint: Gazetteer,
    query_key: 'gazetteer_id',
    smartSelector: {
      tabs: { map: true }
    }
  }
]

export default AssertedEnvironmentObject
