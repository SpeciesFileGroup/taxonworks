<template>
  <div>
    <h1>Biological relationship composer</h1>
    <div class="flex-separate">
      <biological-relationships @selected="setBiologicalRelationship"/>
      <edit-component :biological-relationship="selected"/>
      <properties-component/>
    </div>
  </div>
</template>

<script>

import BiologicalRelationships from './components/BiologicalRelationships/Main'
import PropertiesComponent from './components/Properties/Main'
import EditComponent from './components/Edit/Main'

export default {
  components: {
    BiologicalRelationships,
    EditComponent,
    PropertiesComponent
  },
  data () {
    return {
      selected: undefined
    }
  },
  methods: {
    setBiologicalRelationship (value) {
      this.selected = value
    }
  }
}
</script>