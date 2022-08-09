<template>
  <div>
    <label>Collectors</label>
    <textarea
      rows="2"
      type="text"
      v-model="collectingEvent.verbatim_collectors"/>
  </div>
</template>

<script>

import extendCE from '../../mixins/extendCE.js'

export default {
  mixins: [extendCE]
}
</script>
