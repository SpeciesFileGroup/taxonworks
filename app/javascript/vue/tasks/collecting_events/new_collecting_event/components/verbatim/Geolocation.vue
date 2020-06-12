<template>
  <div class="field label-above">
    <label>Geolocation uncertainty</label>
    <input
      type="text"
      rows="3"
      v-model="collectingEvent.verbatim_geolocation_uncertainty">
  </div>
</template>

<script>

import extendCE from '../mixins/extendCE'

export default {
  mixins: [extendCE]
}
</script>
