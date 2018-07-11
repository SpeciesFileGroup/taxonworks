<template>
  <div>
    <div>
      <label>Buffered determination</label>
      <br>
      <textarea
        v-model="bufferedDetermination"
        rows="5"/>
    </div>
    <div>
      <label>Buffered collecting event</label>
      <br>
      <textarea
        v-model="bufferedCollectionEvent"
        rows="5"/>
    </div>
    <div>
      <label>Buffered other labels</label>
      <br>
      <textarea
        v-model="bufferedOtherLabels"
        rows="5"/>
    </div>
  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations.js'

export default {
  computed: {
    bufferedDetermination: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionObject].buffered_determinations
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionObjectBufferedDeterminations, value)
      }
    },
    bufferedOtherLabels: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionObject].buffered_other_labels
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionObjectBufferedOtherLabel, value)
      }
    },
    bufferedCollectionEvent: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionObject].buffered_collecting_event
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionObjectBufferedCollectionEvent, value)
      }
    }
  }
}
</script>
