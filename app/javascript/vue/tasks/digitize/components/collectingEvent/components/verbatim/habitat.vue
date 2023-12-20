<template>
  <div>
    <label>Habitat</label>
    <input
      type="text"
      v-model="collectingEvent.verbatim_habitat"
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
