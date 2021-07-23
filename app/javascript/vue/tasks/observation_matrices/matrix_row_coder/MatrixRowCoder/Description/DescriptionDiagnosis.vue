<template>
  <div>
    <h2>Diagnosis (generated)</h2>
    <span v-html="diagnosis"/>
  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'

export default {
  computed: {
    diagnosis () {
      const diagnosis = this.$store.getters[GetterNames.GetDescription]?.generated_diagnosis

      return diagnosis === 'Cannot be separated from other rows in the matrix!'
        ? `<span class="red">${diagnosis}</span>`
        : diagnosis
    }
  }
}
</script>
