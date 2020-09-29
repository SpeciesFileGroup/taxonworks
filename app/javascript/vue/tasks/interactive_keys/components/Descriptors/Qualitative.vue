<template>
  <div>
    <label class="display-block">{{ descriptor.name }}</label>
    <select v-model="selected[descriptor.id]">
      <option :value="undefined"/>
      <option
        v-for="state in descriptor.states"
        :value="state.id"
        :key="state.id">
        {{ state.name }} ({{ state.number_of_objects }})
      </option>
    </select>
  </div>
</template>

<script>

import ExtendDescriptor from './shared.js'

export default {
  mixins: [ExtendDescriptor]
}
</script>
