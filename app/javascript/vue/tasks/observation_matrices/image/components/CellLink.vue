<template>
  <a
    v-html="label"
    :href="browseLink(rowObject)"/>
</template>

<script>

import { RouteNames } from 'routes/routes'

const BROWSE_LINK = {
  CollectionObject: (id, _) => `${RouteNames.BrowseCollectionObject}?collection_object_id=${id}`,
  TaxonName: (id, _) => `${RouteNames.BrowseNomenclature}?taxon_name_id=${id}`,
  Otu: (id, rowObject) => rowObject.observation_matrix_id
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
      const objectClass = {
        otu_id: 'Otu',
        collection_object_id: 'CollectionObject',
        taxon_name_id: 'TaxonName'
      }

      const [property, klass] = object.base_class === 'Otu'
        ? ['id', 'Otu']
        : Object.entries(objectClass).find(([key, value]) => object[key])

      return BROWSE_LINK[klass](object[property], object)
    }
  }
}
</script>
