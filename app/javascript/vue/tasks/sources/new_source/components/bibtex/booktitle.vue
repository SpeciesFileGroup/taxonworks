<template>
  <div class="field">
    <label>Booktitle</label><br>
    <textarea v-model="source.booktitle"></textarea>
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
