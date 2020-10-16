<template>
  <div>
    <label class="display-block">{{ descriptor.name }}</label>
    <select v-model="selected[descriptor.id]">
      <option :value="true">Present</option>
      <option :value="false">Absent</option>
    </select>
  </div>
</template>

<script>

import ExtendDescriptor from './shared.js'

export default {
  mixins: [ExtendDescriptor]
}
</script>
