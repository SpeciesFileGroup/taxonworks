<template>
  <div class="field label-above">
    <label>Latitude</label>
    <input
      class="full_width"
      type="text"
      v-model="collectingEvent.verbatim_latitude">
  </div>
</template>

<script>

import extendCE from '../mixins/extendCE'

export default {
  mixins: [extendCE]
}
</script>
