<template>
  <depiction-component
    :object-value="collectionEvent"
    object-type="CollectionEvent"
    action-save="SaveCollectionObject"/>
</template>

<script>

import DepictionComponent from '../../../shared/depictions'
import { GetterNames } from '../../../../store/getters/getters.js'

export default {
  components: {
    DepictionComponent
  },
  computed: {
    collectionEvent() {
      return this.$store.getters[GetterNames.GetCollectionEvent]
    }
  },
}
</script>

<style>

</style>
