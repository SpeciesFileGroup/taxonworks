<template>
  <div>
    <label class="display-block">Language</label>
    <select v-model="languageSelected">
      <option :value="undefined"/>
      <option
        v-for="language in languageList"
        :key="language.id"
        :value="language.id">
        {{ language.english_name }}
      </option>
    </select>
  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'

export default {
  props: {
    modelValue: {
      type: Number,
      default: undefined
    },

    languageList: {
      type: Array,
      default: () => []
    }
  },

  computed: {
    languageSelected: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    },

    observationMatrix () {
      return this.$store.getters[GetterNames.GetObservationMatrix]
    }
  }
}
</script>
