<template>
  <label class="unit-selector separate-left">
    Unit:
    <select v-model="unitSelected">
      <option :value="null">-- none --</option>
      <option
        v-for="(conversion, unit) in units"
        :key="unit"
        :value="unit"
        :selected="modelValue === unit">
        {{ unit }}: {{ conversion }}
      </option>
    </select>
  </label>
</template>

<script>
import { GetterNames } from '../../store/getters/getters'

export default {
  name: 'UnitSelector',

  props: {
    modelValue: String
  },

  emits: ['update:modelValue'],

  computed: {
    units () {
      return this.$store.getters[GetterNames.GetUnits]
    },

    unitSelected: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  }
}
</script>
