<template>
  <div class="field">
    <label>Abstract</label><br>
    <textarea v-model="source.abstract"></textarea>
  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'

export default {
  computed: {
    source: {
      get () {
        return this.$store.getters[GetterNames.GetSource]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSource, value)
      }
    }
  }
}
</script>
