<template>
  <div>
    <label>Date</label>
    <input
      type="text"
      v-model="collectingEvent.verbatim_date">
  </div>
</template>

<script>

import extendCE from '../../mixins/extendCE.js'

export default {
  mixins: [extendCE]
}
</script>
