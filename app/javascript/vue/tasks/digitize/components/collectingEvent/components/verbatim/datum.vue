<template>
  <div>
    <label>Datum</label>
    <input
      type="text"
      v-model="collectingEvent.verbatim_datum"
    >
  </div>
</template>

<script>

import extendCE from '../../mixins/extendCE.js'

export default {
  mixins: [extendCE]
}
</script>
