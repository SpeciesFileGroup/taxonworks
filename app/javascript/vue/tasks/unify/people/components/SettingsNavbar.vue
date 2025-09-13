<template>
  <ul class="context-menu">
    <li>
      <label>
        <input
          type="checkbox"
          v-model="settings.activeJSONRequest"
        >
        Show JSON request
      </label>
    </li>
    <li>
      <label>
        <input
          type="checkbox"
          v-model="settings.showSearch"
        >
        Show filter
      </label>
    </li>
    <li>
      <label>
        <input
          type="checkbox"
          v-model="settings.showFound"
        >
        Show found people
      </label>
    </li>
    <li>
      <label>
        <input
          type="checkbox"
          v-model="settings.showMatch"
        >
        Show match people
      </label>
    </li>
    <li>
      <span
        class="reload-app"
        data-icon="reset"
        @click="$emit('reset')"
      >
        Reset
      </span>
    </li>
  </ul>
</template>

<script>
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'

export default {
  emits: ['reset'],

  computed: {
    settings: {
      get () {
        return this.$store.getters[GetterNames.GetSettings]
      },

      set (value) {
        this.$store.commit(MutationNames.SetSettings, value)
      }
    }
  }
}
</script>
