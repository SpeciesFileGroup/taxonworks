<template>
  <a
    v-html="label"
    :href="browseLink(rowObject)"
  />
</template>

<script>

import { RouteNames } from 'routes/routes'
import {
  OTU,
  COLLECTION_OBJECT,
  TAXON_NAME
} from 'constants/index.js'

const BROWSE_LINK = {
  [COLLECTION_OBJECT]: (id, _) => `${RouteNames.BrowseCollectionObject}?collection_object_id=${id}`,
  [TAXON_NAME]: (id, _) => `${RouteNames.BrowseNomenclature}?taxon_name_id=${id}`,
  [OTU]: (id, rowObject) => rowObject.observation_matrix_id
    ? `${RouteNames.BrowseOtu}?otu_id=${id}&observation_matrix_id=${rowObject.observation_matrix_id}`
    : `${RouteNames.BrowseOtu}?otu_id=${id}`
}

export default {
  props: {
    rowObject: {
      type: Object,
      required: true
    },

    label: {
      type: String,
      required: true
    }
  },

  methods: {
    browseLink (object) {
      const klass = object.observation_object_type || object.base_class
      const objectId = object.observation_object_id || object.id

      return klass in BROWSE_LINK
        ? BROWSE_LINK[klass](objectId, object)
        : ''
    }
  }
}
</script>
