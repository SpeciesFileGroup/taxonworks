<template>
  <div>
    <label>Datum</label>
    <input
      type="text"
      v-model="datum">
  </div>
</template>

<script>

import { GetterNames } from '../../../../store/getters/getters'
import { MutationNames } from '../../../../store/mutations/mutations'

export default {
  computed: {
    datum: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionEvent].verbatim_datum
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionEventDatum, value)
      }
    }
  }
}
</script>