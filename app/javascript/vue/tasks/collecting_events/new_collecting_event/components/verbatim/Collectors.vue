<template>
  <div class="field label-above">
    <label>Collectors</label>
    <textarea
      class="full_width"
      rows="5"
      v-model="collectingEvent.verbatim_collectors"/>
  </div>
</template>

<script>

import extendCE from '../mixins/extendCE'

export default {
  mixins: [extendCE]
}
</script>
