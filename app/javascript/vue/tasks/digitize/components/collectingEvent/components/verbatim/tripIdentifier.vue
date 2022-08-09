<template>
  <div>
    <label>Trip identifier</label>
    <input
      type="text"
      v-model="collectingEvent.verbatim_trip_identifier">
  </div>
</template>

<script>

import extendCE from '../../mixins/extendCE.js'

export default {
  mixins: [extendCE]
}
</script>
