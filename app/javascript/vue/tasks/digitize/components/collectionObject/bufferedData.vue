<template>
  <div class="horizontal-left-content">
    <div>
      <label>Buffered determination</label>
      <br>
      <textarea
        v-model="bufferedDetermination"
        rows="5"/>
      <lock-component
        v-model="locked.collection_object.buffered_determinations"/>
    </div>
    <div>
      <label>Buffered collecting event</label>
      <br>
      <textarea
        v-model="bufferedCollectionEvent"
        rows="5"/>
      <lock-component v-model="locked.collection_object.buffered_collecting_event"/>
    </div>
    <div>
      <label>Buffered other labels</label>
      <br>
      <textarea
        v-model="bufferedOtherLabels"
        rows="5"/>
      <lock-component v-model="locked.collection_object.buffered_other_labels"/>
    </div>
  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations.js'
import LockComponent from 'components/lock.vue'

export default {
  components: {
    LockComponent
  },
  computed: {
    locked: {
      get() {
        return this.$store.getters[GetterNames.GetLocked]
      },
      set(value) {
        this.$store.commit([MutationNames.SetLocked, value])
      }
    },
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
