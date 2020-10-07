<template>
  <div>
    <label class="display-block">Language</label>
    <select v-model="filters.language_id">
      <option :value="undefined"/>
      <option
        v-for="language in observationMatrix.descriptor_available_languages"
        :key="language.id"
        :value="language.id">
        {{ language.english_name }}
      </option>
    </select>
  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'

export default {
  computed: {
    filters: {
      get () {
        return this.$store.getters[GetterNames.GetParamsFilter]
      },
      set (value) {
        this.$store.commit(MutationNames.SetParamsFilter, value)
      }
    },
    observationMatrix () {
      return this.$store.getters[GetterNames.GetObservationMatrix]
    }
  },
  data () {
    return {
      values: [0, 1, 2]
    }
  },
}
</script>
