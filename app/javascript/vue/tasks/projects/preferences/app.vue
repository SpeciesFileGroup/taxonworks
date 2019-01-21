<template>
  <div>
    <h1>Project - Customize attributes.</h1>
    <div>
      <model-component @onSelect="setModel" />
      <predicates-component/>
    </div>
  </div>
</template>

<script>

import ModelComponent from './components/model'
import PredicatesComponent from './components/predicates'

export default {
  components: {
    ModelComponent,
    PredicatesComponent
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