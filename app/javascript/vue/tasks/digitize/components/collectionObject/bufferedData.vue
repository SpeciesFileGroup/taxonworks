<template>
  <div
    v-help.sections.collectionObject.buffered
    class="flexbox buffered-component">
    <div class="separate-right">
      <label>Buffered determination</label>
      <br>
      <div class="horizontal-left-content align-start">
        <textarea
          class="buffered-textarea separate-right"
          v-model="bufferedDetermination"
          rows="5"/>
        <div>
          <lock-component
            v-model="locked.collection_object.buffered_determinations"/>
          <button 
            type="button"
            @click="bufferedDetermination = setInline(bufferedDetermination)"
            class="button button-default margin-small-top">
            Trim
          </button>
        </div>
      </div>
    </div>
    <div class="separate-right separate-left">
      <label>Buffered collecting event</label>
      <br>
      <div class="horizontal-left-content align-start">
        <textarea
          class="buffered-textarea separate-right"
          v-model="bufferedCollectionEvent"
          style="width: 100%"
          rows="5"/>
        <div>
          <lock-component v-model="locked.collection_object.buffered_collecting_event"/>
          <button 
            type="button"
            @click="bufferedCollectionEvent = setInline(bufferedCollectionEvent)"
            class="button button-default margin-small-top">
            Trim
          </button>
        </div>
      </div>
    </div>
    <div class="separate-left">
      <label>Buffered other labels</label>
      <br>
      <div class="horizontal-left-content align-start">
        <textarea
          class="buffered-textarea separate-right"
          v-model="bufferedOtherLabels"
          rows="5"/>
        <div>
          <lock-component
            v-model="locked.collection_object.buffered_other_labels"/>
          <button 
            type="button"
            @click="bufferedOtherLabels = setInline(bufferedOtherLabels)"
            class="button button-default margin-small-top">
            Trim
          </button>
        </div>
      </div>
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
  },
  methods: {
    setInline (text) {
      return text.replace(/\s+|\n|\r/g, " ").trim()
    }
  }
}
</script>
<style lang="scss" scoped>
  .buffered-component {
    width: 100%;

    .buffered-textarea {
      width: 100%
    }
  }

</style>
