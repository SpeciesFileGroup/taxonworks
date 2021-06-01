<template>
  <div class="field label-above">
    <label>Elevation</label>
    <input
      class="full_width"
      type="text"
      rows="3"
      v-model="collectingEvent.verbatim_elevation">
  </div>
</template>

<script>

import extendCE from '../mixins/extendCE'

export default {
  mixins: [extendCE]
}
</script>
