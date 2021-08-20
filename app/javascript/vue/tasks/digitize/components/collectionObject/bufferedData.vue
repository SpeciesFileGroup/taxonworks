<template>
  <div
    v-help.sections.collectionObject.buffered
    class="flexbox full_width"
  >
    <buffered-field
      title="Buffered determination"
      v-model="bufferedDetermination"
      v-model:lock="locked.collection_object.buffered_determinations"
    />
    <buffered-field
      title="Buffered collecting event"
      v-model="bufferedCollectionEvent"
      v-model:lock="locked.collection_object.buffered_collecting_event"
    />
    <buffered-field
      title="Buffered other labels"
      v-model="bufferedOtherLabels"
      v-model:lock="locked.collection_object.buffered_other_labels"
    />
  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations.js'
import BufferedField from './BufferedField.vue'

export default {
  components: { BufferedField },

  computed: {
    locked: {
      get () {
        return this.$store.getters[GetterNames.GetLocked]
      },
      set (value) {
        this.$store.commit(MutationNames.SetLocked, value)
      }
    },

    bufferedDetermination: {
      get () {
        return this.$store.getters[GetterNames.GetCollectionObject].buffered_determinations
      },
      set (value) {
        this.$store.commit(MutationNames.SetCollectionObjectBufferedDeterminations, value)
      }
    },

    bufferedOtherLabels: {
      get () {
        return this.$store.getters[GetterNames.GetCollectionObject].buffered_other_labels
      },
      set (value) {
        this.$store.commit(MutationNames.SetCollectionObjectBufferedOtherLabel, value)
      }
    },

    bufferedCollectionEvent: {
      get () {
        return this.$store.getters[GetterNames.GetCollectionObject].buffered_collecting_event
      },
      set (value) {
        this.$store.commit(MutationNames.SetCollectionObjectBufferedCollectionEvent, value)
      }
    }
  }
}
</script>
