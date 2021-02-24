<template>
  <label class="unit-selector separate-left">
    Unit:
    <select @change="unitSelected">
      <option :value="null">-- none --</option>
      <option
        v-for="(conversion, unit) in units"
        :key="unit"
        :value="unit"
        :selected="value === unit">
        {{ unit }}: {{ conversion }}
      </option>
    </select>
  </label>
</template>

<style lang="stylus" src="./UnitSelector.styl"></style>

<script>
const vModelChangeEventName = 'change'

import { GetterNames } from '../../store/getters/getters'

export default {
  name: 'UnitSelector',
  model: {
    prop: 'value',
    event: vModelChangeEventName
  },
  props: {
    value: String
  },
  computed: {
    units () {
      return this.$store.getters[GetterNames.GetUnits]
    }
  },
  methods: {
    unitSelected (event) {
      this.$emit(vModelChangeEventName, event.target.value)
    }
  }
}
</script>
