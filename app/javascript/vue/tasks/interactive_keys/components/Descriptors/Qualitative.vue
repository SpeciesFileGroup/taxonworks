<template>
  <div>
    <a
      @click="setModalView(true)"
      class="display-block">{{ descriptor.name }}</a>
    <select v-model="selected[descriptor.id]">
      <option :value="undefined"/>
      <option
        v-for="state in descriptor.states"
        :value="state.id"
        :key="state.id">
        {{ state.name }} ({{ state.number_of_objects }})
      </option>
    </select>
    <depictions-container
      v-if="openModal"
      @close="setModalView(false)"
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
    }
  }
}
</script>
