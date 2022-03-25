<template>
  <descriptor-container :descriptor="descriptor">
    <select v-model="selected[descriptor.id]">
      <option :value="true">Present</option>
      <option :value="false">Absent</option>
    </select>
  </descriptor-container>
</template>

<script>

import ExtendDescriptor from './shared.js'

export default {
  mixins: [ExtendDescriptor]
}
</script>
