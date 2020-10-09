<template>
  <div>
    <a
      @click="setModalView(true)"
      class="display-block cursor-pointer">{{ descriptor.name }}</a>
    <select @change="setValue">
      <option :value="undefined"/>
      <option
        v-for="state in descriptor.states"
        :value="state.id"
        :selected="selectedOption(state)"
        :key="state.id">
        <span v-if="selectedOption(state)">></span> {{ state.name }} ({{ state.number_of_objects }})
      </option>
    </select>
    <depictions-container
      v-if="openModal"
      @close="setModalView(false)"
      v-model="selected"
      :descriptor="descriptor"/>
  </div>
</template>

<script>

import ExtendDescriptor from './shared.js'
import DepictionsContainer from './Depictions/DepictionsContainer'

export default {
  mixins: [ExtendDescriptor],
  components: {
    DepictionsContainer
  },
  data () {
    return {
      openModal: false
    }
  },
  methods: {
    setModalView (value) {
      this.openModal = value
    },
    selectedOption (character) {
      return this.selected[this.descriptor.id] ? Array.isArray(this.selected[this.descriptor.id]) ? this.selected[this.descriptor.id].includes(character.id) : this.selected[this.descriptor.id] === character.id : false
    },
    setValue (event) {
      console.log(event.target.value)
      this.selected[this.descriptor.id] = Number(event.target.value)
    }
  }
}
</script>
