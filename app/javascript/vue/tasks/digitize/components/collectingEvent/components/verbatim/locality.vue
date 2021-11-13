<template>
  <div>
    <label>Locality</label>
    <textarea
      id="verbatim-locality"
      rows="5"
      v-model="collectingEvent.verbatim_locality"/>
  </div>
</template>

<script>

import extendCE from '../../mixins/extendCE.js'

export default {
  mixins: [extendCE]
}
</script>
