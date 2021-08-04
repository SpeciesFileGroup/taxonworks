<template>
  <div>
    <label>Date</label>
    <input
      type="text"
      v-model="date">
  </div>
</template>

<script>

import { GetterNames } from '../../../../store/getters/getters'
import { MutationNames } from '../../../../store/mutations/mutations'

export default {
  computed: {
    date: {
      get () {
        return this.$store.getters[GetterNames.GetCollectionEvent].verbatim_date
      },
      set (value) {
        this.$store.commit(MutationNames.SetCollectionEventDate, value)
      }
    }
  }
}
</script>
