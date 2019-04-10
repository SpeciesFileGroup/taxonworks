<template>
  <div>
    <label>Label</label>
    <textarea
      rows="5"
      v-model="label"/>
    <clone-label/>
  </div>
</template>

<script>

import { GetterNames } from '../../../../store/getters/getters'
import { MutationNames } from '../../../../store/mutations/mutations'
import CloneLabel from './cloneLabel'

export default {
  components: {
    CloneLabel
  },
  computed: {
    label: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionEvent].verbatim_label
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionEventLabel, value)
      }
    }
  }
}
</script>