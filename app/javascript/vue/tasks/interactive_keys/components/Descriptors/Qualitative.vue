<template>
  <div>
    <div class="display-block">
      <a
        @click="setModalView(true)"
        class=" cursor-pointer">{{ descriptor.name }}</a>
    </div>
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
    <depictions-container
      v-if="openModal"
      @close="setModalView(false)"
      @update="setValue"
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
    setValue (value) {
      this.$set(this.selected, this.descriptor.id, value)
    }
  }
}
</script>
