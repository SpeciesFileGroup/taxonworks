<template>
  <depiction-component
    :object-value="collectingEvent"
    object-type="CollectingEvent"
    default-message="Drop images or click here<br> to add collecting event figures"
    action-save="SaveCollectingEvent"
  />
</template>

<script>
import DepictionComponent from '../../../shared/depictions'
import { GetterNames } from '../../../../store/getters/getters.js'

export default {
  components: { DepictionComponent },

  computed: {
    collectingEvent() {
      return this.$store.getters[GetterNames.GetCollectingEvent]
    }
  }
}
</script>

<style scoped>
.vue-dropzone {
  padding: 0px !important;
}
</style>
