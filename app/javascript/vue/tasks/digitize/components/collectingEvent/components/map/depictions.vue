<template>
  <depiction-component
    :object-value="collectingEvent"
    object-type="CollectingEvent"
    default-message="Drop images or click here<br> to add collecting event figures"
    :get-depictions="GetCollectingEventDepictions"
    action-save="SaveCollectingEvent"/>
</template>

<script>

import DepictionComponent from '../../../shared/depictions'
import { GetterNames } from '../../../../store/getters/getters.js'
import { CollectingEvent } from 'routes/endpoints'

export default {
  components: { DepictionComponent },

  data () {
    return {
      GetCollectingEventDepictions: CollectingEvent.depictions
    }
  },

  computed: {
    collectingEvent () {
      return this.$store.getters[GetterNames.GetCollectingEvent]
    }
  },
}
</script>

<style scoped>
  .vue-dropzone {
    padding: 0px !important;
  }
</style>
