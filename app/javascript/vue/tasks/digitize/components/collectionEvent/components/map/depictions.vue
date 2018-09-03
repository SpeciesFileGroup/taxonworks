<template>
  <depiction-component
    :object-value="collectionEvent"
    object-type="CollectingEvent"
    :get-depictions="GetCollectionEventDepictions"
    action-save="SaveCollectionEvent"/>
</template>

<script>

import DepictionComponent from '../../../shared/depictions'
import { GetterNames } from '../../../../store/getters/getters.js'
import { GetCollectionEventDepictions } from '../../../../request/resources.js'

export default {
  components: {
    DepictionComponent
  },
  data() {
    return {
      GetCollectionEventDepictions
    }
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
