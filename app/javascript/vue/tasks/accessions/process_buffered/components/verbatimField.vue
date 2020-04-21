<template>
  <div class="field label-above">
    <label class="capitalize">{{ field.replace(/_/g, ' ') }}</label>
    <input
      type="text"
      :class="{ 'field-selected' : field === fieldSelected }"
      @mousedown="fieldSelected = field"
      v-model="collectingEvent[field]">
  </div>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'

export default {
  props: {
    field: {
      type: String,
      required: true
    }
  },
  computed: {
    collectingEvent: {
      get () {
        return this.$store.getters[GetterNames.GetCollectingEvent]
      },
      set (value) {
        this.$store.commit(MutationNames.SetCollectingEvent, value)
      }
    },
    fieldSelected: {
      get () {
        return this.$store.getters[GetterNames.GetTypeSelected]
      },
      set (value) {
        this.$store.commit(MutationNames.SetTypeSelected, value)
      }
    }
  }
}
</script>

<style scoped>
  .field-selected {
    border: 1px solid red
  }
</style>
