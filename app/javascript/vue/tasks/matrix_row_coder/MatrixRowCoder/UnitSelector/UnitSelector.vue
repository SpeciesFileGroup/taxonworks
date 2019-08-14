<template>
  <label class="unit-selector separate-left">
    Unit:
    <select @change="unitSelected">
      <option
        v-for="(conversion, unit) in units"
        :value="unit"
        :selected="value === unit">

        {{ unit }}
      </option>
    </select>
  </label>
</template>

<style lang="stylus" src="./UnitSelector.styl"></style>

<script>
const vModelChangeEventName = 'change'

export default {
  name: 'UnitSelector',
  model: {
    prop: 'value',
    event: vModelChangeEventName
  },
  props: {
    value: String
  },
  data: function () {
    return {
      units: require('../../constants/units.json')
    }
  },
  methods: {
    unitSelected (event) {
      this.$emit(vModelChangeEventName, event.target.value)
    }
  }
}
</script>
