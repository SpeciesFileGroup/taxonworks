import { RouteNames } from '@/routes/routes'

export default {
  TaxonNames: {
    shortcut: 'b',
    path: RouteNames.BrowseNomenclature,
    param: 'taxon_name_id'
  },
  CollectionObjects: {
    shortcut: 'c',
    path: RouteNames.BrowseCollectionObject,
    param: 'collection_object_id'
  },
  Otus: {
    shortcut: 'o',
    path: RouteNames.BrowseOtu,
    param: 'otu_id'
  },
  CollectingEvents: {
    shortcut: 'e',
    path: RouteNames.BrowseCollectingEvent,
    param: 'collecting_event_id'
  },
  Sources: {
    shortcut: 's',
    path: RouteNames.NewSource,
    param: 'source_id'
  }
}
