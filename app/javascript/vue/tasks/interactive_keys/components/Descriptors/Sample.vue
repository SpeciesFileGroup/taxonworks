<template>
  <div>
    <label class="display-block">
      {{ descriptor.name }}
    </label>
    <input
      v-model="selected[descriptor.id]"
      type="number">
  </div>
</template>

<script>
import ExtendDescriptor from './shared.js'

export default {
  mixins: [ExtendDescriptor]
}
</script>
