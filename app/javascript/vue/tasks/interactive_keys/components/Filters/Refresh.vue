<template>
  <div>
    <label class="middle">
      <input
        type="checkbox"
        v-model="settings.refreshOnlyTaxa">
      Refresh only taxa
    </label>
  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'

export default {
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
