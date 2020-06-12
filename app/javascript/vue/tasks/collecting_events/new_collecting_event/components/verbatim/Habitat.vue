<template>
  <div class="field label-above">
    <label>Habitat</label>
    <input
      type="text"
      v-model="collectingEvent.verbatim_habitat">
  </div>
</template>

<script>

import extendCE from '../mixins/extendCE'

export default {
  mixins: [extendCE]
}
</script>
