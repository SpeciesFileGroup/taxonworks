<template>
  <div>
    <label>Method</label>
    <input
      type="text"
      v-model="collectingEvent.verbatim_method"
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
