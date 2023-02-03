<template>
  <descriptor-container
    :descriptor="descriptor"
    v-model="selected"
  >
    <select @change="setValue">
      <option :value="undefined" />
      <option
        v-for="state in descriptor.states"
        :value="state.id"
        :selected="selectedOption(state)"
        :key="state.id"
      >
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
      const selectedCharacters = this.selected[this.descriptor.id]

      if (selectedCharacters) {
        return Array.isArray(selectedCharacters)
          ? selectedCharacters.includes(character.id)
          : selectedCharacters === character.id
      }

      return undefined
    },

    setValue (event) {
      const value = event.target.value

      if (value) {
        this.selected[this.descriptor.id] = Number(value)
      } else {
        delete this.selected[this.descriptor.id]
      }
    }
  }
}
</script>
