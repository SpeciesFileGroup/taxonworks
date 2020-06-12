<template>
  <div class="field label-above">
    <label>Label</label>
    <textarea
      rows="3"
      v-model="collectingEvent.verbatim_label"/>
  </div>
</template>

<script>

import extendCE from '../mixins/extendCE'

export default {
  mixins: [extendCE]
}
</script>
