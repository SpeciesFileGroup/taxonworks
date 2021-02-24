<template>
  <depiction-component
    :object-value="collectionEvent"
    object-type="CollectingEvent"
    default-message="Drop images or click here<br> to add collecting event figures"
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

<style module>
  .vue-dropzone {
    padding: 0px !important;
  }
</style>
