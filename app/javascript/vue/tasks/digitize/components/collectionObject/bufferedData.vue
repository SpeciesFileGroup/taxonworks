<template>
  <div
    v-help.sections.collectionObject.buffered
    class="buffered"
  >
    <buffered-field
      title="Buffered determination"
      v-model="collectionObject.buffered_determinations"
      v-model:lock="locked.collection_object.buffered_determinations"
    />
    <buffered-field
      title="Buffered collecting event"
      v-model="collectionObject.buffered_collecting_event"
      v-model:lock="locked.collection_object.buffered_collecting_event"
    />
    <buffered-field
      title="Buffered other labels"
      v-model="collectionObject.buffered_other_labels"
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

    collectionObject: {
      get () {
        return this.$store.getters[GetterNames.GetCollectionObject]
      },
      set (value) {
        this.$store.commit(MutationNames.SetCollectionObject, value)
      }
    }
  }
}
</script>

<style scoped>
  .buffered {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 0.5em;
  }
</style>
