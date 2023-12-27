<template>
  <div>
    <label>Elevation</label>
    <input
      type="text"
      v-model="collectingEvent.verbatim_elevation"
      @change="updateChange"
    />
  </div>
</template>

<script>
import extendCE from '../../mixins/extendCE.js'

export default {
  mixins: [extendCE]
}
</script>
