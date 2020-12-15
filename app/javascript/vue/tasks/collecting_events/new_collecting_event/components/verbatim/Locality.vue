<template>
  <div class="field label-above">
    <label>Locality</label>
    <textarea
      class="full_width"
      type="text"
      rows="5"
      v-model="collectingEvent.verbatim_locality"/>
  </div>
</template>

<script>

import extendCE from '../mixins/extendCE'

export default {
  mixins: [extendCE]
}
</script>
