<template>
  <descriptor-container :descriptor="descriptor">
    <select v-model="selected[descriptor.id]">
      <option :value="undefined" />
      <option
        v-for="(value, key) in options"
        :value="value"
        :key="key"
      >
        <span v-if="descriptor.status === 'useless'">-</span> {{ key }} ({{ getNumberOfObjects(value) }})
      </option>
    </select>
  </descriptor-container>
</template>

<script>

import ExtendDescriptor from './shared.js'

export default {
  mixins: [ExtendDescriptor],

  data () {
    return {
      options: {
        Present: 'true',
        Absent: 'false'
      }
    }
  },

  methods: {
    getNumberOfObjects (value) {
      return this.descriptor?.states.find(({ name }) => name === value).number_of_objects
    }
  }
}
</script>
