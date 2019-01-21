<template>
  <div>
    <h1>Project - Customize attributes.</h1>
    <div>
      <model-component @onSelect="setModel" />
    </div>
  </div>
</template>

<script>

import ModelComponent from './components/model'

export default {
  components: {
    ModelComponent
  },
  data() {
    return {
      model: undefined
    }
  },
  methods: {
    setModel(model) {
      this.model = model.value
    }
  }
}
</script>