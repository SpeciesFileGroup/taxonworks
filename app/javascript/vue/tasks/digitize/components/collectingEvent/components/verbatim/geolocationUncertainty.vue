<template>
  <div>
    <label>Geolocation uncertainty in meters</label>
    <input
      type="text"
      v-model="collectingEvent.verbatim_geolocation_uncertainty">
  </div>
</template>

<script>

import extendCE from '../../mixins/extendCE.js'

export default {
  mixins: [extendCE]
}
</script>
