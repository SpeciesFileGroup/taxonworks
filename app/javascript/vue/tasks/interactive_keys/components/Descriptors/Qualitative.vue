<template>
  <descriptor-container
    :descriptor="descriptor"
    v-model="selected"
  >
    <select @change="setValue(Number($event.target.value))">
      <option :value="undefined"/>
      <option
        v-for="state in descriptor.states"
        :value="state.id"
        :selected="selectedOption(state)"
        :key="state.id">
        <span v-if="selectedOption(state)">></span> <span v-if="state.status === 'useless'">-</span> {{ state.name }} ({{ state.number_of_objects }})
      </option>
    </select>
  </descriptor-container>
</template>

<script>
import ExtendDescriptor from './shared.js'

export default {
  mixins: [ExtendDescriptor],

  methods: {
    selectedOption (character) {
      return this.selected[this.descriptor.id] ? Array.isArray(this.selected[this.descriptor.id]) ? this.selected[this.descriptor.id].includes(character.id) : this.selected[this.descriptor.id] === character.id : false
    },

    setValue (value) {
      this.selected[this.descriptor.id] = value
    }
  }
}
</script>
